class UhcLeaderboardEntry
    include Mongoid::Document
    include ApiModel
    include ApiAnnounceable
    store_in database: 'oc_uhc_entries'

    belongs_to :user, class_name: 'User'

    field :kills_solo,   type: Integer, default: 0
    field :kills_teams,   type: Integer, default: 0
    field :gold_solo,   type: Integer, default: 0
    field :gold_teams,   type: Integer, default: 0
    field :wins_solo,   type: Integer, default: 0
    field :wins_teams,   type: Integer, default: 0

    # User is required via relation, but intentionally not exposed to the API
    # since we have the synthetic below which creates a PlayerId.
    # The API is never actually responsible for creating these, since we do that here.
    required = [:_id]
    optional = [:kills_solo, :kills_teams, :gold_solo, :gold_teams, :wins_solo, :wins_teams]

    attr_accessible       *required, *optional, :user_id
    api_property          *required, *optional
    validates_presence_of *required

    api_synthetic :user do
        user.api_player_id
    end

    def self.for_user(user)
      res = where(user: user).first
      if res.nil?
        res = new(user_id: user.id)
        res.save
      end
      res
    end
end
