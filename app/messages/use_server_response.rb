# Sent in response to a server use request.
# Contains the server the player should be directed to.
# If the server is nil, this means the server is not currently joinable but should be soon.
class UseServerResponse < Reply
    field :server_name # Bungee name
    field :now # Is the server instantly joinable
end
