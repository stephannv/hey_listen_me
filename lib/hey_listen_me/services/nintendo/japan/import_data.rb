require_relative '../../process_raw_infos'

module Nintendo
  module Japan
    class ImportData < Actor
      play FetchData, ::ProcessRawInfos
    end
  end
end
