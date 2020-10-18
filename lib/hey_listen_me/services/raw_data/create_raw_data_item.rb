module RawData
  class CreateRawDataItem < Actor
    input :data_source, type: String, in: DataSource.list
    input :external_id, type: String
    input :data, type: Hash

    input :repository, type: RawDataItemRepository, default: -> { RawDataItemRepository.new }

    output :old_raw_data_item, type: RawDataItem, allow_nil: true
    output :new_raw_data_item, type: RawDataItem, allow_nil: true

    def call
      raw_data_item = repository.find_by_data_source_and_external_id(data_source: data_source, external_id: external_id)
      self.old_raw_data_item = raw_data_item
      self.new_raw_data_item = if raw_data_item.nil?
        create_raw_data_item
      else
        update_raw_data_item(raw_data_item: raw_data_item)
      end
    end

    private

    def create_raw_data_item
      repository.create(
        data_source: data_source,
        external_id: external_id,
        data: sorted_data,
        checksum: data_checksum,
        imported: false
      )
    end

    def update_raw_data_item(raw_data_item:)
      return if data_checksum == raw_data_item.checksum

      repository.update(raw_data_item.id, data: sorted_data, checksum: data_checksum, imported: false)
    end

    def sorted_data
      @sorted_data ||= data.deep_sort
    end

    def data_checksum
      @data_checksum ||= Digest::MD5.hexdigest(sorted_data.except(*IgnoredKeys::LIST[data_source]).to_s)
    end
  end
end
