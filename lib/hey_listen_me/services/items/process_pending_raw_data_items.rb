module Items
  class ProcessPendingRawDataItems < Actor
    input :raw_data_item_repository, type: RawDataItemRepository, default: -> { RawDataItemRepository.new }

    def call
      raw_data_item_repository.not_imported.each do |raw_data_item|
        Items::ProcessRawDataItem.call(raw_data_item: raw_data_item)
      end
    end
  end
end
