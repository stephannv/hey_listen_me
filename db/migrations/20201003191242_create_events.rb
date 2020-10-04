Hanami::Model.migration do
  change do
    create_table :events do
      primary_key :id

      foreign_key :raw_info_id, :raw_infos, type: 'uuid', on_delete: :restrict, null: false

      column :type, String, null: false
      column :changes, 'jsonb', default: '{}'

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
