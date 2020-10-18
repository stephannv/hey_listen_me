module RawData
  class ImportRawDataCollection < Actor
    input :data_source, type: String, in: DataSource.list
    input :external_id_key, type: String
    input :raw_data, type: Array

    def call
      raw_data_size = raw_data.size
      index = 0

      while index < raw_data_size
        data_item = raw_data[index]
        RawData::ImportRawDataItem.call(
          data_source: data_source, external_id: data_item[external_id_key], data: data_item
        )
        index += 1
      end
    end
  end
end
