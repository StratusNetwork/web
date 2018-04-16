require 'signet/oauth_2/client'
require 'google/api_client'
require 'discordrb/light'

REDIRECT_URI = "http://localhost:3000/oauth2callback"

Rails.configuration.oauth2_client_secrets = {
    :youtube => Google::APIClient::ClientSecrets.new(
        'web' => {
            client_id: ENV["GOOGLE_CLIENT_ID"] || "876303339553-fm44mll20q9oskk8f1ld5ihavggr6llb.apps.googleusercontent.com",
            client_secret: ENV["GOOGLE_CLIENT_SECRET"] || "MjBmUOliORksL6eQ_-FixH1K",
            redirect_uri: "http://localhost:3000/oauth2callback",
            javascript_origin: REDIRECT_URI,
        }
    ),
    :github => Signet::OAuth2::Client.new(
        :authorization_uri => 'https://github.com/login/oauth/authorize',
        :token_credential_uri => 'https://github.com/login/oauth/access_token',
        :client_id => ENV['GITHUB_CLIENT_ID'] || '2b7497802e3eb6d70b0e',
        :client_secret => ENV['GITHUB_CLIENT_SECRET'] || 'bc1c3d4669cd97fa30f62cb8ab367c1262e9cd66',
        :scope => 'read:user',
        :redirect_uri => REDIRECT_URI
    ),
    :discord => Signet::OAuth2::Client.new(
        :authorization_uri => 'https://discordapp.com/api/oauth2/authorize',
        :token_credential_uri => 'https://discordapp.com/api/oauth2/token',
        :client_id => ENV['DISCORD_CLIENT_ID'] || '430081112056791050',
        :client_secret => ENV['DISCORD_CLIENT_SECRET'] || 's-zhwKbHa1igPDYnMM1hwDcgganN7uwK',
        :scope => 'identify',
        :redirect_uri => REDIRECT_URI
    )
}
