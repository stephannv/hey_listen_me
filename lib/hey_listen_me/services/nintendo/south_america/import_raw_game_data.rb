require_relative '../../raw_data/import_raw_data_collection'

module Nintendo
  module SouthAmerica
    class ImportRawGameData < Actor
      play FetchRawGameData, RawData::ImportRawDataCollection
    end
  end
end
