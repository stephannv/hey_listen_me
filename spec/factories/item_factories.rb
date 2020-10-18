FactoryBot.define do
  factory :item do
    id { SecureRandom.uuid }
    raw_data_item_id { SecureRandom.uuid }
    data_source { DataSource.list.sample }
    data { Hash[*Faker::Lorem.words(number: 8)] }
    checksum { Digest::MD5.hexdigest(data.deep_sort.to_s) }
  end
end
