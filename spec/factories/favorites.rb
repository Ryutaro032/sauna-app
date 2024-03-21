FactoryBot.define do
  factory :favorite do
    association :user
    association :facility
  end
end
