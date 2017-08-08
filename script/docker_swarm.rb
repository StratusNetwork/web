# Worker that maintains the stability of the Docker swarm.

Raven.capture
Rails.logger = logger = Logger.new(STDOUT)
logger.formatter = -> (severity, datetime, progname, msg) do
    "[#{datetime} #{severity}] #{msg}\n"
end

Rails.logger.info "Docker daemon started!"
Swarm.ensure!

todo = Server.with_orchestration.to_a
Rails.logger.info todo

todo.each do |server|

	server.deploy!

end