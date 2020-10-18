class RawDataItemRepository < Hanami::Repository
  def find_by_data_source_and_external_id(data_source:, external_id:)
    raw_data_items.where(data_source: data_source, external_id: external_id).one
  end

  def not_imported
    raw_data_items.where(imported: false)
  end
end
