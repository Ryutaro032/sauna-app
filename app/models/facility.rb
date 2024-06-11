class Facility < ApplicationRecord
  geocoded_by :address
  after_validation :geocode, if: :address_changed?
  has_many :favorites, dependent: :destroy
  has_many :users, through: :favorites

  def favorited_by?(user)
    favorites.exists?(user: user)
  end

  def self.search_places(params)
    if params[:prefecture_id].present? && params[:city_id].present?
      prefecture_name = Prefecture.find(params[:prefecture_id])&.name
      city_name = City.find(params[:city_id])&.name
      query = "#{prefecture_name} #{city_name},サウナ"
    elsif params[:prefecture_id].present?
      prefecture_name = Prefecture.find(params[:prefecture_id])&.name
      query = "#{prefecture_name},サウナ"
    elsif params[:word].present?
      query = "#{params[:word]},サウナ"
    elsif params[:place_name].present?
      query = params[:place_name]
    end

    return nil if query.blank?

    client = ::GooglePlaces::Client.new(ENV.fetch('GOOGLE_API_KEY'))
    client.spots_by_query(query, language: 'ja', type: '"point_of_interest", "establishment","spa"')
  end

  def self.search_places_and_save(params)
    places = search_places(params)
    return nil if places.blank?

    places.each do |place|
      existing_facility = Facility.find_by(place_id: place.place_id)
      next if existing_facility

      Facility.create(
        name: place.name,
        address: place.formatted_address,
        latitude: place.lat,
        longitude: place.lng,
        place_id: place.place_id
      )
    end
  end
end
