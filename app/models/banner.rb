class Banner
    include Mongoid::Document
    include Mongoid::Timestamps
    include EagerLoadable
    store_in :database => "oc_banners"

    class Type < Enum
        create :WEB, :MOTD

        def self.parse(str)
            case str
            when 'web'
                WEB
            when 'motd'
                MOTD
            else
                raise "Unknown banner type! " + str
            end
        end
    end

    field :type, type: Type, default: Type::MOTD
    field :text, type: String, validates: {presence: true}
    field :active, type: Boolean, default: false, validates: {presence: true}
    field :weight, type: Float, default: 1.0, validates: {presence: true}
    field :expires_at, type: Time, validates: {presence: true}

    scope :active, -> { where(active: true).gt(expires_at: Time.now) }

    attr_accessible :text, :active, :weight, :expires_at, :type

    before_save do
        render('US') if type == Type::MOTD # Ensure this works before saving
    end

    after_save do
        Server.bungees.online.each(&:api_sync!) if type == Type::MOTD
    end

    TITLE = "§b§lStratus Network"
    PIXELS = 263

    class << self
        def active(type)
            now = Time.now
            imap_all.select do |banner|
                banner.type == type && banner.active_at(time: now)
            end
        end

        def make_motd_top(text)
            ChatUtils.padded_heading("╔", text, "╗", width: PIXELS, pad: "═", pad_color: ChatColor::BLUE)
        end

        def make_motd_bottom(text)
            ChatUtils.padded_heading("╚", text, "╝", width: PIXELS, pad: "═", pad_color: ChatColor::BLUE)
        end

        def make_motd(datacenter:, title: TITLE, message: nil)
            top = make_motd_top(title)
            bottom = if message
                         make_motd_bottom(message)
                     else
                         "§9╚#{ "═" * 28 }╝" # Must increase PIXELS to 269 if we ever want this
                     end
            [top, bottom].join("\n")
        end


        def make_web_alert(message)
            parts = message.split(':')
            level = parts[0]
            level = 'info' unless level == 'alert' || level == 'success' || level == 'danger'
            icon = parts[1]
            bold = parts[2]
            text = parts[3]

            level = "alert alert-" + level
            icon = "fa " + icon
            text = MARKDOWN.render(text)
            text = text.slice(3, text.length).slice(0, text.length - 3)

            "<div class=\"#{level}\" id=\"banner-alert\">
                <strong>
                  <i class=\"#{icon}\"></i>
                  #{bold}
                </strong>
                #{text}
              </div>"
        end
    end

    def render(datacenter = nil)
        case type
        when Type::MOTD
            raise 'Datacenter cannot be nil' unless datacenter
            self.class.make_motd(datacenter: datacenter.to_s.upcase, message: self.text)
        when Type::WEB
            self.class.make_web_alert(self.text)
        end
    end

    def active_at(time: nil)
        active? && expires_at > (time || Time.now)
    end

    def expires?
        expires_at != Time::INF_FUTURE
    end

end
