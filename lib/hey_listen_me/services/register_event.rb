class RegisterEvent < Actor
  input :old_raw_info, type: RawInfo, allow_nil: true
  input :new_raw_info, type: RawInfo, allow_nil: true

  input :event_repository, type: EventRepository, default: -> { EventRepository.new }

  def call
    return if new_raw_info.nil?

    check_if_raw_infos_has_the_same_id

    event_repository.create(type: event_type, raw_info_id: new_raw_info.id, changes: changes)
  end

  private

  def check_if_raw_infos_has_the_same_id
    raise 'DIFFERENT RAW INFOS' if old_raw_info && old_raw_info.id != new_raw_info.id
  end

  def event_type
    if old_raw_info.nil?
      EventType::CREATE
    else
      EventType::UPDATE
    end
  end

  def changes
    data_source = new_raw_info.data_source
    old_data = old_raw_info&.data.to_h.except(*IgnoredKeys::LIST[data_source])
    new_data = new_raw_info.data.to_h.except(*IgnoredKeys::LIST[data_source])

    Hashdiff.diff(old_data, new_data)
  end
end
