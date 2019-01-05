class Server
    module Ownable
        extend ActiveSupport::Concern
        include Lifecycle

        included do
            # If this server is requestable
            field :ownable, default: false
            attr_accessible :ownable
            api_property :ownable
            
            # User who owns this server
            belongs_to :user
            field_scope :user
            api_property :user_id
            attr_cloneable :user
        end # included do

        module ClassMethods
            def owned
                Server.where(:user.exists => true)
            end

            def free_for_requests
                Server.where(user: nil, ownable: true)
            end
        end
    end # Owned
 end
