# Request to use a certain server.
class UseServerRequest < BaseMessage
    field :user_id

    def user
        User.need(user_id)
    end
end
