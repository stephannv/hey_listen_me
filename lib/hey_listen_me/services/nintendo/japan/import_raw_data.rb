require_relative '../../raw_data/process'

module Nintendo
  module Japan
    class ImportRawData < Actor
      play FetchRawData, RawData::Process
    end
  end
end
