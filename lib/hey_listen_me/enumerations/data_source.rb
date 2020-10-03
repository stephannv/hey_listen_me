class DataSource < EnumerateIt::Base
  associate_values(
    :nintendo_europe,
    :nintendo_japan,
    :nintendo_north_america,
    :nintendo_brasil
  )
end
