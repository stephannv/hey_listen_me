class EventRepository < Hanami::Repository
  associations do
    belongs_to :raw_info
  end
end
