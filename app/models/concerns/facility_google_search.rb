module FacilityGoogleSearch
  extend ActiveSupport::Concern

  class_methods do
    def search_places(params)
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
  end
end
