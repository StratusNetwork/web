class User
    module Chat
        extend ActiveSupport::Concern

        included do
            field :chat_channel, type: String, default: "TEAM".freeze
            api_property :chat_channel
            attr_accessible :chat_channel
        end
    end
end
