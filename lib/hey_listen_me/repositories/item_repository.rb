class ItemRepository < Hanami::Repository
  def find_by_raw_data_item_id(raw_data_item_id)
    items.where(raw_data_item_id: raw_data_item_id).one
  end
end
