require 'google/api_client'

Rails.configuration.tap do |config|
    config.google = {
        :production => {
            :secret => "...",
            :identifier => "..."
        },

        :development => {
            :secret => "...",
            :identifier => "..."
        }
    }

    config.google_encode = "..."

    config.google_api_key = ENV["GOOGLE_API_KEY"] || "AIzaSyC2xi1TP31gSt06L2UX8nozqr0JMcwMGr4"
end

module GOOGLE
    extend self

    def new_client(**options)
        options[:authorization] ||= nil # Without this, it creates an OAuth2 client
        options[:key] &&= Rails.configuration.google_api_key
        Google::APIClient.new(application_name: 'website', **options)
    end

    CLIENT = new_client
    KEY_CLIENT = new_client(key: true)
    YOUTUBE = KEY_CLIENT.discovered_api('youtube', 'v3')
end

