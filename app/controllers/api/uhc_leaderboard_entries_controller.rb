module Api
    class UhcLeaderboardEntriesController < ModelController
        controller_for UhcLeaderboardEntry

        def get_or_create
            user = User.by_player_id(params['player_id']) or raise NotFound
            entry = UhcLeaderboardEntry.for_user(user)
            respond(entry.api_document)
        end
    end
end
