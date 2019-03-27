# Request to use a certain server.
class UseServerRequest < BaseMessage
    field :user_id
    field :server_name

    def user
        User.need(user_id)
    end

    def name
        (server_name.blank?) ? user.username : server_name
    end
end
