module ApiPublic
  class UsersController < ApiPublicController
    include FormattingHelper

    public

    def by_username
      user = User.by_username(params[:username]) or raise NotFound
      respond({permissions: user.mc_permissions_by_realm, flairs: user.minecraft_flair, banned: user.is_banned?})
    end

    def by_uuid
      user = User.by_uuid(params[:uuid]) or raise NotFound
      respond({permissions: user.mc_permissions_by_realm, flairs: user.minecraft_flair, banned: user.is_banned?})
    end

  end
end

