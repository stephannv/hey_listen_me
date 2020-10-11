class DataSource < EnumerateIt::Base
  associate_values(
    :nintendo_europe,
    :nintendo_japan,
    :nintendo_north_america,
    :nintendo_brasil
  )

  LABELS = {
    'nintendo_europe' => '🇪🇺 Nintendo Europe',
    'nintendo_japan' => '🇯🇵 Nintendo Japan',
    'nintendo_north_america' => '🇨🇦🇲🇽🇺🇸 Nintendo North America',
    'nintendo_brasil' => '🇧🇷 Nintendo Brasil'
  }.freeze

  def self.humanize(data_source)
    LABELS[data_source]
  end
end
