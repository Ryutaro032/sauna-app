FactoryBot.define do
  factory :opening_hour do
    facility
    day_of_week { Faker::Number.between(from: 0, to: 6) }
    opening_time { Time.zone.parse('09:00') }
    closing_time { Time.zone.parse('17:00') }
    holiday { false }
  end
end
