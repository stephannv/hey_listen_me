class RawDataChangelog < Hanami::Entity
  attributes do
    attribute :id, Types::String

    attribute :raw_data_item_id, Types::String

    attribute :event_type, Types::String
    attribute :changes, Types::Hash

    attribute :created_at, Types::DateTime
    attribute :updated_at, Types::DateTime
  end
end
