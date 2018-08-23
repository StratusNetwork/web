case Rails.env
    when 'development', 'staging', 'production'
        Calendar.new(
            id: "uhc",
            source: "j9eeoiq0jeb7qicstkk6ann1p0@group.calendar.google.com",
            announce: true,
            announce_range: 3
        )
end
