Hanami::Model.migration do
  change do
    create_table :raw_infos do
      primary_key :id, 'uuid', null: false, default: Hanami::Model::Sql.function(:uuid_generate_v4)

      column :data_source, String, null: false, size: 128
      column :external_id, String, null: false, size: 128
      column :data, 'jsonb', default: '{}'
      column :checksum, String, null: false, size: 512

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index %i[data_source external_id], unique: true
    end
  end
end
