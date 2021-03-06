FactoryBot.define do
  factory :raw_data_item do
    id { SecureRandom.uuid }
    data_source { DataSource.list.sample }
    external_id { Faker::Crypto.md5 }
    data { Hash[*Faker::Lorem.words(number: 8)] }
    checksum { Digest::MD5.hexdigest(data.deep_sort.to_s) }
    imported { Faker::Boolean.boolean }
  end
end
