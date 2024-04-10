class Facility < ApplicationRecord
  geocoded_by :address
  after_validation :geocode, if: :address_changed?
  has_many :favorites, dependent: :destroy
  has_many :users, through: :favorites

  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end

  def self.search_places(params)
    if params[:prefecture].present? && params[:city].present?
      prefecture_name = Prefecture.find(params[:prefecture])&.name
      city_name = City.find(params[:city])&.name
      query = "#{prefecture_name} #{city_name},サウナ"
    elsif params[:prefecture].present?
      prefecture_name = Prefecture.find(params[:prefecture])&.name
      query = "#{prefecture_name},サウナ"
    elsif params[:word].present?
      query = "#{params[:word]},サウナ"
    end

    return nil unless query.present?

    client = ::GooglePlaces::Client.new(ENV.fetch('GOOGLE_API_KEY'))
    client.spots_by_query(query, language: 'ja', type: '"point_of_interest", "establishment","spa"')
  end
end
