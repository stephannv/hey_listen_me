class RawDataItem < Hanami::Entity
  attributes do
    attribute :id, Types::String

    attribute :data_source, Types::String
    attribute :external_id, Types::String
    attribute :data, Types::Hash
    attribute :checksum, Types::String
    attribute :imported, Types::Bool

    attribute :created_at, Types::DateTime
    attribute :updated_at, Types::DateTime
  end
end
