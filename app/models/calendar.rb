class Calendar
    include MiniModel

    field :source           # Full google calendar ID
    field :announce         # If events in the near future should be shown on the home page
    field :announce_range   # Days before an event that it should be considered for announcement

end
