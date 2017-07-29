
Rails.configuration.tap do |config|
    config.servers = {
        cloudflare: {
            api_key: '...',
            email: '...'
        },

        digitalocean: {
            access_token: ENV['DIGITAL_OCEAN_ACCESS_TOKEN']
        },

        dns: {
            zone: 'stratus.network',
            enabled_prefix: 'online',
            disabled_prefix: 'offline',
            ttl: 60.seconds,
            resolve_timeout: 5.seconds,
        },

        # Minimum bungees online at any given time
        datacenters: {
            'US' => { minimum_bungees: 1 },
            'EU' => { minimum_bungees: 1 },
            'AU' => { minimum_bungees: 0 },
            'AS' => { minimum_bungees: 0 }
        }
    }
end
