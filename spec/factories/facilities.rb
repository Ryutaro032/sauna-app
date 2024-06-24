FactoryBot.define do
  factory :facility do
    name { Faker::Company.name }
    address { Faker::Address.full_address }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    place_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    min_price { Faker::Number.number(digits: 4) }
    max_price { min_price + Faker::Number.number(digits: 3) }
    free_text { Faker::Lorem.paragraph }
    outdoor_bath { false }
    rest_area { false }
    aufguss { false }
    auto_louver { false }
    self_louver { false }
    sauna_mat { 'なし' }
    bath_towel { 'なし' }
    face_towel { 'なし' }
    in_house_wear { 'なし' }
    work_space { false }
    in_house_rest_area { false }
    restaurant { false }
    wifi { false }
    comics { false }

    after(:create) do |facility|
      (0..6).each do |day|
        next unless facility.opening_hours.any? { |oh| oh.day_of_week == day }

        create(:opening_hour, facility: facility, day_of_week: day)
      end
    end
  end
end
