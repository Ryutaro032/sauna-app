FactoryBot.define do
  factory :opening_hour do
    facility
    day_of_week { Faker::Number.between(from: 0, to: 6) }
    opening_time { Time.zone.now.beginning_of_day + rand(6.hours) }
    closing_time { opening_time + rand(6.hours) }
    holiday { false }
  end
end
