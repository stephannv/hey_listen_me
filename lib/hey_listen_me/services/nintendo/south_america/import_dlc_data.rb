require_relative '../../process_raw_infos'

module Nintendo
  module SouthAmerica
    class ImportDlcData < Actor
      play FetchDlcData, ::ProcessRawInfos
    end
  end
end
