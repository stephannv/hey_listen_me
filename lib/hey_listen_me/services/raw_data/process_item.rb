module RawData
  class ProcessItem < Actor
    play CreateItem, CreateChangelog
  end
end
