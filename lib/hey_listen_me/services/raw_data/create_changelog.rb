module RawData
  class CreateChangelog < Actor
    input :old_raw_data_item, type: RawDataItem, allow_nil: true
    input :new_raw_data_item, type: RawDataItem, allow_nil: true

    input :raw_data_changelog_repository,
      type: RawDataChangelogRepository,
      default: -> { RawDataChangelogRepository.new }

    def call
      return if new_raw_data_item.nil?

      check_if_raw_data_items_has_the_same_id

      raw_data_changelog_repository.create(
        event_type: event_type,
        raw_data_item_id: new_raw_data_item.id,
        changes: changes
      )
    end

    private

    def check_if_raw_data_items_has_the_same_id
      raise 'DIFFERENT RAW DATA ITEMS' if old_raw_data_item && old_raw_data_item.id != new_raw_data_item.id
    end

    def event_type
      if old_raw_data_item.nil?
        EventType::CREATE
      else
        EventType::UPDATE
      end
    end

    def changes
      data_source = new_raw_data_item.data_source
      old_data = old_raw_data_item&.data.to_h.except(*IgnoredKeys::LIST[data_source])
      new_data = new_raw_data_item.data.to_h.except(*IgnoredKeys::LIST[data_source])

      Hashdiff.diff(old_data, new_data)
    end
  end
end
