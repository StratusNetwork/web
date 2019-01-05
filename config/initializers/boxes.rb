case Rails.env
    when 'development', 'staging', 'production'
        Box.define do
            box Box.local_id do
                hostname Socket.gethostname
                workers [RepoWorker,
                         CouchWorker,
                         ModelSearchWorker,
                         EngagementWorker,
                         TaskWorker,
                         MatchMaker,
                         CalendarWorker,
                         PrivateServerManager,
                         #ChartWorker,
                         #ChannelWorker,
                         (ServerReportWorker if Dog.client)].compact
                services [:octc]
            end
        end
end
