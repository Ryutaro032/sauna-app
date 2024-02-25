FactoryBot.define do
  factory :user do
    name { Faker::Name.last_name }
    email { Faker::Internet.free_email }
    password { 'password' }
    password_confirmation { 'password' }
    my_rule { Faker::Lorem.paragraph }

    after(:build) do |user|
      user.icon_image.attach(io: File.open('spec/fixtures/files/image_test.jpg'), filename: 'image_test.jpg')
    end
  end
end
