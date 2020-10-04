class ImportRawInfo < Actor
  input :data_source, type: String, in: DataSource.list
  input :external_id, type: String
  input :data, type: Hash
  input :ignored_keys_for_checksum, type: Array, default: []

  input :raw_info_repository, type: RawInfoRepository, default: -> { RawInfoRepository.new }

  output :old_raw_info, type: RawInfo, allow_nil: true
  output :new_raw_info, type: RawInfo, allow_nil: true

  def call
    raw_info = raw_info_repository.by_data_source_and_external_id(data_source: data_source, external_id: external_id)
    self.old_raw_info = raw_info
    self.new_raw_info = if raw_info.nil?
      create_raw_info
    else
      update_raw_info(raw_info: raw_info)
    end
  end

  private

  def create_raw_info
    raw_info_repository.create(
      data_source: data_source, external_id: external_id, data: sorted_data, checksum: data_checksum
    )
  end

  def update_raw_info(raw_info:)
    return if data_checksum == raw_info.checksum

    raw_info_repository.update(raw_info.id, data: sorted_data, checksum: data_checksum)
  end

  def sorted_data
    @sorted_data ||= data.deep_sort
  end

  def data_checksum
    @data_checksum ||= Digest::MD5.hexdigest(sorted_data.except(*ignored_keys_for_checksum).to_s)
  end
end
