module Api
    class UhcLeaderboardEntriesController < ModelController
        controller_for Chat

        def get_or_create
            user = User.find(params['user_id']) or raise NotFound
            entry = UhcLeaderboardEntry.for_user(user)
            respond(entry.api_document)
        end
    end
end
