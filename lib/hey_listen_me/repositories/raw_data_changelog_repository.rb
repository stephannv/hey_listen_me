class RawDataChangelogRepository < Hanami::Repository
  associations do
    belongs_to :raw_data_item
  end
end
