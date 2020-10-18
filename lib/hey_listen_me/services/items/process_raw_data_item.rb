module Items
  class ProcessRawDataItem < Actor
    play CreateItem, CreateItemChangelog
  end
end
