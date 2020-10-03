require_relative '../../import_raw_infos'

module Nintendo
  module Europe
    class ImportData < Actor
      play FetchData, ::ImportRawInfos
    end
  end
end
