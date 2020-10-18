module RawData
  class ImportRawDataItem < Actor
    play CreateRawDataItem, CreateChangelog
  end
end
