class RawDataItemRepository < Hanami::Repository
  def by_data_source_and_external_id(data_source:, external_id:)
    raw_data_items.where(data_source: data_source, external_id: external_id).one
  end
end
