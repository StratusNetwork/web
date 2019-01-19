# A single-threaded worker that handles private server requests

require "kubeclient"
require "celluloid/current"
require "celluloid/io"

class PrivateServerManager
  include QueueWorker

  queue :use_server
  consumer exclusive: true, manual_ack: false

  topic_binding UseServerRequest

  around_event :dequeue do |_, yielder|
    ApiSyncable.syncing(&yielder)
  end

  poll delay: 1.minutes do
    Server.owned.each do |s|
      next if s.num_online > 0

      # Kill empty servers
      s.queue_restart(reason: "Automated server reset", priority: Server::Restart::Priority::HIGH) if s.online?
    end

    # Keep 1 avaliable server ready at all times
    if Server.free_for_requests.empty?
      create_server
    end
  end

  handle UseServerRequest do |request|
    ApiSyncable.syncing do
      user = request.user
      server = Server.find_by(user: user)
      if server.nil?
        server = Server.free_for_requests.first
        if server.nil?
          server = create_server
        end
        claim_server(server, user)
      end
      create_pod(server) unless server_online?(server)
      res = UseServerResponse.new(request: request)
      res.server_name = server.bungee_name
      res.now = server.online?
      res
    end
  end

  protected

  def server_online?(s)
    begin
      p = cluster.get_pod(s.bungee_name, 'default').status.phase
      p == "Running" || p == "Pending"
    rescue
      false
    end
  end

  def create_server
    index = Server.owned.size + Server.free_for_requests.size + 1
    name = "Requestable-#{index}"
    Server.create(
      name: name,
      bungee_name: name.downcase,
      ip: name.downcase,
      priority: 40 + index,
      online: false,
      whitelist_enabled: true,
      settings_profile: "private",
      datacenter: "US",
      box: "production",
      family: "pgm",
      role: "PGM",
      network: "PUBLIC",
      visibility: "UNLISTED",
      startup_visibility: "UNLISTED",
      realms: ["global", "normal", "private"],
      operator_ids: [],
      ownable: true,
      user_id: nil
    )
  end

  def claim_server(server, user)
    name = user.username
    bungee_name = name.downcase
    ip = bungee_name
    server.update(name: name,
      bungee_name: bungee_name,
      ip: ip,
      operator_ids: [user._id],
      user: user
    )
  end

  def create_pod(server)
    logger.info "Creating service for " + server.name
    service = Kubeclient::Resource.new
    service.metadata = {
      name: server.bungee_name,
      labels: {
        role: 'private',
        type: 'minecraft',
        user: server.bungee_name
      },
      namespace: 'default'
    }
    service.spec = {
      clusterIP: 'None',
      ports: [
        {
          port: 25565,
          name: 'minecraft'
        }
      ],
      selector: {
        user: server.bungee_name
      }
    }
    cluster.create_service(service)
    logger.info "Creating pod for " + server.name
    pod = Kubeclient::Resource.new
    pod.metadata = {
      name: server.bungee_name,
      labels: {
        role: 'private',
        type: 'minecraft',
        user: server.bungee_name
      },
      namespace: 'default'
    }
    pod.spec = {
      nodeSelector: {
        private: 'true'
      },
      containers: [
        {
          name: 'minecraft',
          image: 'gcr.io/stratus-197318/minecraft:bukkit-master',
          imagePullPolicy: 'Always',
          ports: [
            {containerPort: 25565, name: 'minecraft', protocol: 'TCP'}
          ],
          readinessProbe: {
            initialDelaySeconds: 15,
            periodSeconds: 15,
            timeoutSeconds: 5,
            exec: {
              command: [
                'ruby',
                'run.rb',
                'ready?'
              ]
            }
          },
          livenessProbe: {
            initialDelaySeconds: 60,
            periodSeconds: 30,
            timeoutSeconds: 5,
            exec: {
              command: [
                'ruby',
                'run.rb',
                'alive?'
              ]
            }
          },
          stdin: true,
          tty: true,
          resources: {
            requests: {
              cpu: '100m',
              memory: '500Mi'
            }
          },
          envFrom: [
            {
              secretRef: {
                name: 'minecraft-secret'
              }
            }
          ],
          volumeMounts: [
            {
              name: 'maps',
              mountPath: '/minecraft/maps:ro'
            }
          ]
        }
      ],
      volumes: [
        {
          name: 'maps',
          hostPath: {
            path: '/storage/maps-private'
          }
        }
      ]
    }
    cluster.create_pod(pod)
  end

  def cluster
    @cluster ||= begin
      cluster_internal
    rescue
      cluster_external
    end
  end

  # Access the cluster from inside a pod that has a service account.
  def cluster_internal
    Kubeclient::Client.new(
      "https://kubernetes.default.svc",
      "v1",
      {
        ssl_options: {
          ca_file: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
        },
        auth_options: {
          bearer_token_file: "/var/run/secrets/kubernetes.io/serviceaccount/token"
        },
        socket_options: {
          socket_class: Celluloid::IO::TCPSocket,
          ssl_socket_class: Celluloid::IO::SSLSocket
        }
      }
    )
  end

  # Access the cluster from an external machine.
  def cluster_external
    config = Kubeclient::Config.read(File.expand_path("~/.kube/config"))
    context = config.context
    ssl_options = context.ssl_options
    ssl_options[:verify_ssl] = 0
    Kubeclient::Client.new(
      context.api_endpoint,
      context.api_version,
      {
        ssl_options: ssl_options,
        auth_options: context.auth_options,
        socket_options: {
          socket_class: Celluloid::IO::TCPSocket,
          ssl_socket_class: Celluloid::IO::SSLSocket
        }
      }
    )
  end
end
