class ProcessRawInfos < Actor
  input :data_source, type: String, in: DataSource.list
  input :external_id_key, type: String
  input :raw_data, type: Array
  input :ignored_keys_for_checksum, type: Array, default: []

  def call
    raw_data_size = raw_data.size
    index = 0

    while index < raw_data_size
      data = raw_data[index]
      ProcessRawInfo.call(
        data_source: data_source, external_id: data[external_id_key], data: data,
        ignored_keys_for_checksum: ignored_keys_for_checksum
      )
      index += 1
    end
  end
end
