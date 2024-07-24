class Facility < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :place_visits, dependent: :destroy
  has_many :users, through: :favorites
  has_many :posts, dependent: :destroy
  has_many :opening_hours, dependent: :destroy
  has_one_attached :facility_icon
  accepts_nested_attributes_for :opening_hours, allow_destroy: true

  after_initialize :initialize_opening_hours, if: :new_record?

  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  validates_associated :opening_hours

  validates :min_price, :max_price, numericality: { greater_than_or_equal_to: 0, allow_nil: true, message: I18n.t('activerecord.errors.models.facility.attributes.price') }
  validate :max_price_greater_than_min_price
  validate :closing_time_after_opening_time
  validates :free_text, length: { maximum: 1200, message: I18n.t('activerecord.errors.models.facility.attributes.free_text.too_long') }

  def favorited_by?(user)
    favorites.exists?(user: user)
  end

  def place_visited_by?(user)
    place_visits.exists?(user: user)
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
        place_id: place.place_id,
        facility_icon: nil,
        min_price: nil,
        max_price: nil,
        free_text: nil,
        outdoor_bath: nil,
        rest_area: nil,
        aufguss: nil,
        auto_louver: nil,
        self_louver: nil,
        sauna_mat: nil,
        bath_towel: nil,
        face_towel: nil,
        in_house_wear: nil,
        work_space: nil,
        in_house_rest_area: nil,
        restaurant: nil,
        wifi: nil,
        comics: nil
      )
    end
  end

  def self.conditional_search(params)
    facilities = Facility.all

    facilities = facilities.where(outdoor_bath: true) if params[:outdoor_bath] == "1"
    facilities = facilities.where(rest_area: true) if params[:rest_area] == "1"
    facilities = facilities.where(aufguss: true) if params[:aufguss] == "1"
    facilities = facilities.where(auto_louver: true) if params[:auto_louver] == "1"
    facilities = facilities.where(self_louver: true) if params[:self_louver] == "1"
    facilities = facilities.where(sauna_mat: params[:sauna_mat]) if params[:sauna_mat].present?
    facilities = facilities.where(bath_towel: params[:bath_towel]) if params[:bath_towel].present?
    facilities = facilities.where(face_towel: params[:face_towel]) if params[:face_towel].present?
    facilities = facilities.where(in_house_wear: params[:in_house_wear]) if params[:in_house_wear].present?
    facilities = facilities.where(work_space: true) if params[:work_space] == "1"
    facilities = facilities.where(in_house_rest_area: true) if params[:in_house_rest_area] == "1"
    facilities = facilities.where(restaurant: true) if params[:restaurant] == "1"
    facilities = facilities.where(wifi: true) if params[:wifi] == "1"
    facilities = facilities.where(comics: true) if params[:comics] == "1"

    facilities
  end

  private

  def max_price_greater_than_min_price
    return unless max_price.present? && min_price.present? && max_price < min_price

    errors.add(:base, '正しい料金を入れてください')
  end

  def closing_time_after_opening_time
    opening_hours.each do |oh|
      next if oh.holiday?

      next unless oh.opening_time.present? && oh.closing_time.present? && oh.closing_time < oh.opening_time

      errors.add(:base, '閉店時間は開店時間より後の時間に設定してください')
    end
  end

  def initialize_opening_hours
    (0..6).each do |day|
      opening_hours.build(day_of_week: day, holiday: false) unless opening_hours.any? { |oh| oh.day_of_week == day }
    end
  end
end
