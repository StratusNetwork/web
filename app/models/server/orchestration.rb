class Server
    module Orchestration
        extend ActiveSupport::Concern

        included do

            # True when this server is allowed to be automatically
            # managed by a Docker swarm. The server will rotate around
            # avaliable nodes with the most resources avaiable in the
            # swarm and will not be confined to a specific node.
            field :orchestration_enabled, type: Boolean

            # Path to the docker-stack.yml file relative to /minecraft/repo/stack folder.
            # This is a manifest that tells Docker what to build when deploying. The file
            # can contain environment variables ${like_this} that will be filled with server
            # api fields automatically.
            field :orchestration_stack_file, type: String

            # The ID of the Docker swarm node that this server should run on. If the
            # node is unavailable, then the server will not be deployed.
            field :orchestration_node_id, type: String

            # True if the server should not restart after turning off. The server
            # will only restart in the event of a system failure.
            field :orchestration_ephemeral, type: Boolean

            # The time at which the server was initially deployed to the Docker swarm.
            field :orchestration_deployed_at, type: Time

            # The time at which the server encountered a deployment error.
            field :orchestration_errored_at, type: Time

            # Error message from the docker daemon about why deployment failed.
            field :orchestration_error, type: String

            properties = [
                :orchestration_enabled, :orchestration_stack_file, :orchestration_node_id, :orchestration_ephemeral,
                :orchestration_deployed_at, :orchestration_errored_at, :orchestration_error
            ]

            api_property *properties
            attr_cloneable *properties
            #attr_accessible *properties

            scope :with_orchestration, where(orchestration_enabled: true)
            #scope :configure, where(:orchestration_id => nil)
            #scope :deployed, where(:orchestration_id.ne => nil)

        end

        def stack_name
            "minecraft_#{role.to_s.downcase}_#{id}"
        end

        def stack_node
            if node = orchestration_node_id && node != nil && !node.empty?
                node
            else
                "none"
            end
        end

        def stack_variables
            variables = api_document.map{|k,v| [k,v.to_s]}.to_h
            variables['node'] = stack_node
            variables
        end

        def stack_restart_condition
            orchestration_ephemeral ? "on-failure" : "any"
        end

        def stack_services
            Swarm.services(stack_name) if deployed?
        end

        def stack_path
            "/Users/fun/Desktop/docker/docker-stack/new/#{orchestration_stack_file}.yml" # "/minecraft/repo/stack"
        end

        def stack_path_exists?
            if orchestration_stack_file
                if file = File.file?(stack_path)
                    return true
                else
                    mark_errored!("Cannot find stack file at '#{stack_path}'")
                end
            else
                mark_errored!("Not stack file provided")
            end
            return false
        end

        def deployed?
            orchestration_deployed_at != nil
        end

        def deploy!
            if orchestration_enabled && stack_path_exists?
                Rails.logger.info stack_variables
                if system(stack_variables, "docker stack deploy -c #{stack_path} #{stack_name}")
                    update!
                    self.orchestration_deployed_at = Time.now
                    self.orchestration_errored_at = nil
                    self.orchestration_error = nil
                    save!
                else
                    undeploy!
                    mark_errored!("Unable to deploy stack\n#{$?}")
                end
            end
        end

        def undeploy!
            unless reuslt = system("docker stack rm #{stack_name}")
                mark_errored!("Unable to remove stack\n#{$?}")
            end
            self.orchestration_deployed_at = nil
            save!
        end

        def update!
            stack_services.each do |service|
                Swarm.update(service, orchestration_ephemeral, 5*60)
            end
        end

        def mark_errored!(message)
            self.orchestration_deployed_at = nil
            self.orchestration_errored_at = Time.now
            self.orchestration_error = message
            save!
        end

        def try!
            if block_given?
                begin
                    yield
                rescue Exception => e
                    mark_errored!("Unable to perform action\n#{e}")
                    false
                end
            end
            true
        end

        module ClassMethods
        end

    end
end
