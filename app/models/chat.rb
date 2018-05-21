class Chat
    include Mongoid::Document
    include BackgroundIndexes
    include ApiModel
    include ApiAnnounceable
    store_in database: 'oc_chats'

    class Type < Enum
        create :TEAM, :SERVER, :ADMIN, :BROADCAST
    end

    class Destination < Enum
        create :SERVER, :FAMILY, :GAME, :NETWORK, :GLOBAL
    end

    class Broadcast
        include Mongoid::Document
        include ApiModel
        embedded_in :chat

        field :destination, type: Destination
        field :id,          type: String

        properties = [:destination, :id]

        attr_accessible       *properties
        api_property          *properties
        validates_presence_of :destination
    end

    belongs_to :sender, class_name: 'User'
    belongs_to :server, class_name: 'Server'
    belongs_to :match,  class_name: 'Match'

    field :message,   type: String
    field :type,      type: Type
    field :broadcast, type: Broadcast
    field :sent_at,   type: Time, default: Time.now

    required = [:_id, :server_id, :message, :type, :sent_at]
    optional = [:sender_id, :match_id, :broadcast]

    attr_accessible       *required, *optional
    api_property          *required, *optional
    validates_presence_of *required

    unset_if_nil :broadcast

    api_synthetic :sender do
        sender.api_player_id if sender
    end

    index(INDEX_sent_at = {sent_at: -1})
    index(INDEX_sender  = {sender_id: 1, sent_at: -1})
    index(INDEX_server  = {server_id: 1, sent_at: -1})
    index(INDEX_message = {message: 1,   sent_at: -1})
    index(INDEX_match   = {match_id: 1,  sent_at: -1})

    scope :sender,  -> (user_id)   { where(sender_id: user_id).hint(INDEX_sender) }
    scope :server,  -> (server_id) { where(server_id: server_id).hint(INDEX_server) }
    scope :match,   -> (match_id)  { where(match_id: match_id).hint(INDEX_match) }
    scope :after,   -> (date)      { gte(sent_at: date).hint(INDEX_sent_at) }
    scope :message, -> (query)     { where(message: /^#{query}/).hint(INDEX_message) }
end
