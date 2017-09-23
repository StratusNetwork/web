class User
    module Themes
        extend ActiveSupport::Concern

        included do
            field :web_theme, type: String, default: Default
            attr_accessible :web_theme, as: :user
        end
    end
end
