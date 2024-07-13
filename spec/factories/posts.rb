FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    review { Faker::Lorem.paragraph(sentence_count: 4) }
    name { Faker::Name.name }
    user
    facility
  end
end
