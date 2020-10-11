require_relative '../../raw_data/process'

module Nintendo
  module SouthAmerica
    class ImportRawGameData < Actor
      play FetchRawGameData, RawData::Process
    end
  end
end
