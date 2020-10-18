class ItemType < EnumerateIt::Base
  associate_values(
    :game,
    :dlc,
    :bundle,
    :voucher,
    :subscription
  )
end
