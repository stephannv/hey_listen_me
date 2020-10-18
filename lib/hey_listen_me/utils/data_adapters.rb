class DataAdapters
  LIST = {
    'nintendo_europe' => Nintendo::EuropeDataAdapter,
    'nintendo_japan' => Nintendo::JapanDataAdapter,
    'nintendo_north_america' => Nintendo::NorthAmericaDataAdapter,
    'nintendo_brasil' => Nintendo::SouthAmericaDataAdapter
  }.freeze
end
