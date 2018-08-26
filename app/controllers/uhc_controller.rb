class UhcController < ApplicationController
    layout "application"

    Event = Struct.new(:summary, :description, :all_day, :event_start_date, :event_end_date, :event_start_time, :event_end_time, :same_day, :add_link, :tweet_link)

    def schedule
        raw = REDIS.get("calendars:uhc:upcoming")
        raw ||= '{}'
        events_raw = JSON.parse(raw)
        events_raw = Hash[events_raw.first(15)] # Only show max of 15 events
        @events = {}

        # The hash returned has raw date strings, we parse them here to cut down on view complexity
        # We also add some helper fields for the sake of the view
        events_raw.each do |k, event|
            summary = event["summary"]
            description = event["description"].present? ? event["description"] : "<i>No description</i>"

            all_day = event["start_date"].present? && event["start_time"].nil?

            event_start_date = all_day ? Date.parse(event["start_date"]) : Date.parse(event["start_time"])
            event_start_time = all_day ? DateTime.parse(event["start_date"]) : DateTime.parse(event["start_time"])

            # NOTE: We subtract 1 second because all day events technically end the next day at 0:00.
            event_end_date = all_day ? (DateTime.parse(event["end_date"]) - 1.second).to_date : Date.parse(event["end_time"])
            event_end_time = all_day ? (DateTime.parse(event["end_date"]) - 1.second).end_of_day : DateTime.parse(event["end_time"])

            same_day = event_start_date == event_end_date

            add_link = "https://www.google.com/calendar/render?action=TEMPLATE" +
                        "&text=#{CGI.escape summary}" +
                        "&dates=#{event_start_time.strftime('%Y%m%dT%H%M%S')}/#{event_end_time.strftime('%Y%m%dT%H%M%S')}" +
                        "&details=#{description}" +
                        "&location=stratus.network" +
                        "&sf=true&output=xml"

            text = "A #{summary} is happening in #{time_ago_in_words(event_start_time)} on stratus.network! @StratusMC #minecraft"
            tweet_link = "http://twitter.com/home?status=" + CGI.escape(text)

            @events[k] = Event.new(
                summary,            # Title of the event
                description,        # Long description of the event (HTML)
                all_day,            # Does the event last all day
                event_start_date,   # DATE when the event starts
                event_end_date,     # DATE when the event ends
                event_start_time,   # TIME when the event starts
                event_end_time,     # TIME when the event ends
                same_day,           # Does the event start and end on the same day
                add_link,           # Add to google calendar link
                tweet_link          # Link to post a tweet
            )
        end
    end

    def leaderboard
        @entries = UhcLeaderboardEntry.all
        @sorts = {
            "wins_solo" => "wins during solo games",
            "wins_teams" => "wins during team games",
            "wins_overall" => "overall wins",
            "gold" => "gold mined during all games",
            "kills" => "kills during all games"
        }
        @sort = choice_param(:sort, @sorts.keys)
        @per_page = PGM::Application.config.global_per_page
        params[:page] = [1, current_page, (@entries.count.to_f / @per_page).ceil].sort[1]

        case @sort.to_sym
        when :wins_solo
            @entries = @entries.sort_by{|e| e.wins_solo}
        when :wins_teams
            @entries = @entries.sort_by{|e| e.wins_teams}
        when :gold
            @entries = @entries.sort_by{|e| e.gold_solo + e.gold_teams}
        when :kills
            @entries = @entries.sort_by{|e| e.kills_solo + e.kills_teams}
        else
            @entries = @entries.sort_by{|e| e.wins_solo + e.wins_teams}
        end

        @entries = @entries.reverse

        page = if @user = username_param and row = UhcLeaderboardEntry.find(user_id: @user.id)
            params.delete(:user)
            1 + (@entries.index(row) - 1) / @per_page
        end

        @entries = Kaminari.paginate_array(@entries).page(page ? page : params[:page]).per(PGM::Application.config.global_per_page)
    end
end
