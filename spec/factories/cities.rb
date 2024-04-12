FactoryBot.define do
  factory :city do
    name { Faker::Address.city }
    prefecture
  end
end
