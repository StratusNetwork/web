class User
    module Themes
        extend ActiveSupport::Concern

        included do
            field :web_theme, type: String
            attr_accessible :web_theme, as: :user
        end

        def dark_theme?
            web_theme == "Dark Theme"
        end
    end
end
