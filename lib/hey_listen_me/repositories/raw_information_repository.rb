class RawInfoRepository < Hanami::Repository
  def by_data_source_and_external_id(data_source:, external_id:)
    raw_infos.where(data_source: data_source, external_id: external_id).limit(1).first
  end

  def games_with_dlc_from_south_america(data_source:)
    raw_infos
      .where(data_source: 'nintendo_brasil')
      .where { data.contain(item_type: 'game', data: { is_dlc_available: true }) }
  end
end
