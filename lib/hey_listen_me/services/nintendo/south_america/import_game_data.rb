require_relative '../../process_raw_infos'

module Nintendo
  module SouthAmerica
    class ImportGameData < Actor
      play FetchGameData, ::ProcessRawInfos
    end
  end
end
