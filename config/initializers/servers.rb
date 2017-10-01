
Rails.configuration.tap do |config|
    config.servers = {
        cloudflare: {
            api_key: ENV['CLOUDFLARE_API_KEY'],
            email: ENV['CLOUDFLARE_EMAIL']
        },

        digitalocean: {
            access_token: ENV['DIGITAL_OCEAN_ACCESS_TOKEN']
        },

        dns: {
            zone: ENV['CLOUDFLARE_ZONE'],
            enabled_prefix: nil,
            disabled_prefix: 'offline',
            ttl: 60.seconds,
            resolve_timeout: 5.seconds,
        },

        # Minimum bungees online at any given time
        datacenters: {
            'US' => { minimum_bungees: 0 },
            'EU' => { minimum_bungees: 0 },
            'AU' => { minimum_bungees: 0 },
            'AS' => { minimum_bungees: 0 },
            'SA' => { minimum_bungees: 0 }
        }
    }
end
