class IgnoredKeys
  IGNORED_KEYS_FOR_NINTENDO_EUROPE = %w[
    _version_
    popularity
    price_discount_percentage_f
    price_has_discount_b
    price_lowest_f
    price_sorting_f
    price_discounted_f
  ].freeze

  IGNORED_KEYS_FOR_NINTENDO_JAPAN = %w[score current_price drate[0] sale_flg].freeze

  LIST = {
    'nintendo_europe' => IGNORED_KEYS_FOR_NINTENDO_EUROPE,
    'nintendo_japan' => IGNORED_KEYS_FOR_NINTENDO_JAPAN,
    'nintendo_north_america' => [],
    'nintendo_brasil' => []
  }.freeze
end
