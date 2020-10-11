class RawInfo < Hanami::Entity
  attributes do
    attribute :id, Types::String

    attribute :data_source, Types::String
    attribute :external_id, Types::String
    attribute :data, Types::Hash
    attribute :checksum, Types::String

    attribute :created_at, Types::DateTime
    attribute :updated_at, Types::DateTime

    attribute :events, Types::Collection(Event)
  end
end
