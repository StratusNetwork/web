class User
    module Connections
        extend ActiveSupport::Concern
        include Mongoid::Document

        class Account
            include Mongoid::Document
            include DisablePolymorphism
            embedded_in :user

            field :id, type: String
            field :username, type: String

            belongs_to :token, class_name: 'User::OAuth::Token'

            attr_accessible :id, :username, :token, :token_id

            def initialize
                super
                refresh!
            end

            def refresh!
                if token?
                    refresh
                    save!
                else
                    destroy!
                end
            end

            def service
                token.service if token
            end

            def url
                raise NotImplementedError, "Cannot find URL to account"
            end

            protected

            def refresh
                raise NotImplementedError, "Cannot refresh account from token"
            end

            def token?
                user.find_oauth2_token_for(self.service).fresh_client rescue false
            end

            class << self #module ClassMethods
                def connect(user, token)
                    user.connections << self.new(token: token)
                    user.save
                end
            end

            class Discord < Account
                def refresh
                    profile = Discordrb::Light::LightBot.new(token.access_token).profile
                    self.id = profile.id
                    self.username = profile.usernaname + "#" + profile.discriminator
                end
                def url
                    "<discord server link>"
                end
            end

            class Github < Account
                def refresh
                    profile = Github.new(oauth_token: token.access_token).users.get
                    self.id = profile.id
                    self.username = profile.login
                end
                def url
                    "https://github.com/#{username}"
                end
            end
        end

        included do
            embeds_many :connections, class_name: 'User::Connections::Account'
            index({'connections.service' => 1})
        end

    end
end
