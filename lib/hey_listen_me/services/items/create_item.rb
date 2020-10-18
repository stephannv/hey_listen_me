module Items
  class CreateItem < Actor
    input :raw_data_item, type: RawDataItem

    input :item_repository, type: ItemRepository, default: -> { ItemRepository.new }
    input :raw_data_item_repository, type: RawDataItemRepository, default: -> { RawDataItemRepository.new }

    output :old_item, type: Item, allow_nil: true
    output :new_item, type: Item, allow_nil: true

    def call
      self.old_item = item_repository.find_by_raw_data_item_id(raw_data_item.id)

      self.new_item = if old_item.nil?
        create_item
      else
        update_item(old_item)
      end

      raw_data_item_repository.update(raw_data_item.id, { imported: true })
    end

    private

    def create_item
      item_repository.create(
        raw_data_item_id: raw_data_item.id,
        data_source: raw_data_item.data_source,
        data: parsed_data,
        checksum: parsed_data_checksum
      )
    end

    def update_item(item)
      return if item.checksum == parsed_data_checksum

      item_repository.update(item.id, { data: parsed_data, checksum: parsed_data_checksum })
    end

    def parsed_data
      @parsed_data ||= begin
        adapter = DataAdapters::LIST[raw_data_item.data_source].new(raw_data_item.data)
        adapter.adapt.deep_sort
      end
    end

    def parsed_data_checksum
      @parsed_data_checksum ||= Digest::MD5.hexdigest(parsed_data.to_s)
    end
  end
end
