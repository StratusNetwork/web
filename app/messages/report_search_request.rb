class ReportSearchRequest < FindRequest
    field :cross_server
    field :server_id
    field :user_id

    def initialize(criteria: {}, **opts)
        super criteria: criteria,
              model: Report,
              **opts
    end
end
