class Swarm
    class << self
        def enabled?
            @enabled ||= begin
                connect!
                true
            rescue
                false
            end
        end

        def connect!
            @connection ||= Docker::Swarm::Connection.new('unix:///var/run/docker.sock')
            @swarm ||= Docker::Swarm::Swarm.find(@connection)
        end

        def ensure!
            Rails.logger.info "Connecting..."
            begin
                swarm = connect!
                Rails.logger.info "Success!"
                return swarm
            rescue Exception => e
                Rails.logger.warn "Failed! Trying again in 30 seconds...\n#{e}"
                sleep(30)
                return ensure!
            end
        end

        def hosts
            @swarm.nodes.map(&:host_name)
        end

        def services(stack)
            @swarm.services.select{|service| service.name.starts_with?(stack)}
        end

        def update(service, restart = true, monitor = "1m")
            image = 
            restart_condition = 
            system("
                docker service update 
                    --image=#{service.hash['Spec']['TaskTemplate']['ContainerSpec']['Image'].split('@')[0]}
                    --restart-condition=#{restart ? 'any' : 'on-failure'}
                    --
            ")

            sec *= 1000000000
            h = service.hash["Spec"]
            Rails.logger.info(service.hash)

            h["UpdateConfig"]["FailureAction"] = "rollback"
            service.update(h)
            return true
            service.update({
                "TaskTemplate" => {
                    "ContainerSpec" => {
                        "Image" => 
                    },
                    "RestartPolicy" => {
                        "Condition" => restart ? "any" : "on-failure"
                    }
                },
                "UpdateConfig" => {
                    "FailureAction" => "rollback",
                    "Monitor" => sec
                },
                "RollbackConfig" => {
                    "Monitor" => sec
                }
            })
            service.reload()
        end
    end
end
