module ApiPublic
  class TeamsController < ApiPublicController
    include FormattingHelper

    public

    def by_name
      team = Team.by_name(params[:name]) or raise NotFound
      respond(team.members_uuid)
    end

  end
end

