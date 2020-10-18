require_relative '../../raw_data/import_raw_data_collection'

module Nintendo
  module NorthAmerica
    class ImportRawData < Actor
      play FetchRawData, RawData::ImportRawDataCollection
    end
  end
end
