class UhcController < ApplicationController
    layout "application"

    def leaderboard
        @entries = UhcLeaderboardEntry.all
        @sorts = {
            "wins_solo" => "wins during solo games",
            "wins_teams" => "wind during team games",
            "gold" => "gold mined during all games",
            "kills" => "kills during all games"
        }
        @sort = choice_param(:sort, @sorts.keys)
        @per_page = PGM::Application.config.global_per_page
        params[:page] = [1, current_page, (@entries.count.to_f / @per_page).ceil].sort[1]

        case @sort.to_sym
        when :wins_solo
            @entries = @entries.sort{|e| e.wins_solo}
        when :wins_teams
            @entries = @entries.sort{|e| e.wins_teams}
        when :gold
            @entries = @entries.sort{|e| e.gold_solo + e.gold_teams}
        when :kills
            @entries = @entries.sort{|e| e.kills_solo + e.kills_teams}
        else
            @entries = @entries.sort{|e| e.wins_solo + e.wins_teams}
        end

        page = if @user = username_param and row = UhcLeaderboardEntry.find(user_id: @user.id)
            params.delete(:user)
            1 + (@entries.index(row) - 1) / @per_page
        end

        @entries = Kaminari.paginate_array(@entries.reverse)
        @entries = a_page_of(@entries, per_page: @per_page)
    end
end
