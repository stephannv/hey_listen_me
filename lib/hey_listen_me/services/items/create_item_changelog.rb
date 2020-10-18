module Items
  class CreateItemChangelog < Actor
    input :old_item, type: Item, allow_nil: true
    input :new_item, type: Item, allow_nil: true

    input :item_changelog_repository, type: ItemChangelogRepository, default: -> { ItemChangelogRepository.new }

    def call
      return if new_item.nil?

      check_if_old_item_and_new_item_have_different_ids

      item_changelog_repository.create(
        item_id: new_item.id,
        event_type: event_type,
        changes: Hashdiff.diff(old_item&.data.to_h, new_item.data.to_h)
      )
    end

    private

    def check_if_old_item_and_new_item_have_different_ids
      raise 'DIFFERENT ITEMS' if old_item && old_item.id != new_item.id
    end

    def event_type
      if old_item.nil?
        EventType::CREATE
      else
        EventType::UPDATE
      end
    end
  end
end
