class RawInfoRepository < Hanami::Repository
  def by_data_source_and_external_id(data_source:, external_id:)
    raw_infos.where(data_source: data_source, external_id: external_id).limit(1).first
  end
end
