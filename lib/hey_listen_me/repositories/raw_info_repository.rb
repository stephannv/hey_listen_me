class RawInfoRepository < Hanami::Repository
  associations do
    has_many :events
  end

  def by_data_source_and_external_id(data_source:, external_id:)
    raw_infos.where(data_source: data_source, external_id: external_id).limit(1).first
  end

  def find_with_events(id)
    aggregate(:events).where(id: id).map_to(RawInfo).one
  end
end
