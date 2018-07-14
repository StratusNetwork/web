module Objective
    class FlagCapture < Base
        include Colored

        field :net_id

        attr_accessible :net_id
        api_property :net_id

        def self.total_description(count)
            "#{"flag".pluralize(count)} captured"
        end
    end
end
