class Server
    module CrossServer
        extend ActiveSupport::Concern

        included do
            field :cross_server_profile, type: String, default: nil

            blank_to_nil    :cross_server_profile
            attr_cloneable  :cross_server_profile
            attr_accessible :cross_server_profile
            api_property    :cross_server_profile

            scope :cross_server, -> (profile) { where(cross_server_profile: profile) }
        end

        module ClassMethods
            def with_cross_servers(server)
                if profile = server.cross_server_profile
                    cross_server(profile)
                else
                    where(id: server.id)
                end
            end
        end
    end
end
