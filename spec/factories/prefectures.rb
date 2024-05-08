FactoryBot.define do
  factory :prefecture do
    name { Faker::Address.unique.city }

    transient do
      cities_count { 3 }
    end

    after(:create) do |prefecture, evaluator|
      create_list(:city, evaluator.cities_count, prefecture: prefecture)
    end
  end
end
