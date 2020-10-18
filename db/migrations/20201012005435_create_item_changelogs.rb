Hanami::Model.migration do
  change do
    create_table :item_changelogs do
      primary_key :id, 'uuid', null: false, default: Hanami::Model::Sql.function(:uuid_generate_v4)

      foreign_key :item_id, :items, type: 'uuid', on_delete: :restrict, null: false

      column :event_type, String, null: false
      column :changes, 'jsonb', default: '{}'

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index %i[item_id created_at]
    end
  end
end
