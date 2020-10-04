class Event < Hanami::Entity
  attributes do
    attribute :id, Types::String

    attribute :raw_info_id, Types::String

    attribute :type, Types::String
    attribute :changes, Types::Hash

    attribute :created_at, Types::DateTime
    attribute :updated_at, Types::DateTime
  end
end
