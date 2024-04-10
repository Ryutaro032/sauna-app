FactoryBot.define do
  factory :city do
    name { Faker::Address.city }
    association :prefecture, factory: :prefecture
  end
end
