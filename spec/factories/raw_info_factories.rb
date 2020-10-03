FactoryBot.define do
  factory :raw_info do
    data_source { DataSource.list.sample }
    external_id { Faker::Crypto.md5 }
    data { Hash[*Faker::Lorem.words(number: 8)] }
    checksum { Digest::MD5.hexdigest(data.deep_sort.to_s) }
  end
end
