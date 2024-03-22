FactoryBot.define do
  factory :facility do
    name { Faker::Company.name }
    address { Faker::Address.full_address }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    place_id { Faker::Alphanumeric.alphanumeric(number: 10) }
  end
end
