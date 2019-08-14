module ApiPublic
  class UsersController < ApiPublicController
    include FormattingHelper

    public

    def by_username
      user = User.by_username(params[:username]) or raise NotFound
      respond({permissions: user.mc_permissions_by_realm, flairs: user.minecraft_flair, banned: user.is_in_game_banned?})
    end

    def by_uuid
      user = User.by_uuid(params[:uuid]) or raise NotFound
      respond({permissions: user.mc_permissions_by_realm, flairs: user.minecraft_flair, banned: user.is_in_game_banned?})
    end

    def check_ban
      user = User.by_uuid(params[:uuid]) or raise NotFound
      banned = user.is_in_game_banned?
      reason = make_nice_reason(Punishment.current_ban(user))
      respond({banned: banned, reason: reason})
    end

    private

    def make_nice_reason(punishment)
      return "If you're seing this, someone screwed up." if punishment.nil?
      str = ChatColor::RED + "You're #{punishment.past_tense_verb} on the "
      str += ChatColor::GOLD + "Legacy Network\n\n"
      str += ChatColor::BLUE + "Reason: " + ChatColor::YELLOW + punishment.reason + "\n"
      str += ChatColor::BLUE + "Issued By: " + ChatColor::YELLOW + punishment.punisher_name + "\n\n"
      str += ChatColor::BLUE + "Visit " + ChatColor::AQUA + "https://#{ORG::DOMAIN}/appeal" + ChatColor::BLUE + " to appeal."
      str
    end
  end
end
