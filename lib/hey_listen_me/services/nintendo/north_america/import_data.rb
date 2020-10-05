require_relative '../../process_raw_infos'

module Nintendo
  module NorthAmerica
    class ImportData < Actor
      play FetchData, ::ProcessRawInfos
    end
  end
end
