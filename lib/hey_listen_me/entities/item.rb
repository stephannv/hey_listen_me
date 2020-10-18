class Item < Hanami::Entity
  attributes do
    attribute :id, Types::String

    attribute :raw_data_item_id, Types::String

    attribute :data_source, Types::String
    attribute :data, Types::Hash
    attribute :checksum, Types::String

    attribute :created_at, Types::DateTime
    attribute :updated_at, Types::DateTime
  end
end
