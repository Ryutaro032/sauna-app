# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'

file_path = 'lib/自治体.csv'
csv_data = CSV.read(file_path, encoding: 'UTF-8')

prefectures_list = csv_data.map { |row| row[1] }.uniq

cities_list = csv_data.map do |row|
  next if row[2] == nil
  row[1, 2]
end.compact

prefectures_list.each do |prefecture|
  Prefecture.create!(name: prefecture)
end

cities_list.each do |prefecture, city|
  prefecture = Prefecture.find_by(name: prefecture)
  prefecture.cities.create(name: city)
end

Dir.glob(File.join(Rails.root, 'db', 'seeds', '*.rb')) do |file|
  load(file)
end
