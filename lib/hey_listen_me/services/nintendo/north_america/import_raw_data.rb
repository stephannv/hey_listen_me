require_relative '../../raw_data/process'

module Nintendo
  module NorthAmerica
    class ImportRawData < Actor
      play FetchRawData, RawData::Process
    end
  end
end
