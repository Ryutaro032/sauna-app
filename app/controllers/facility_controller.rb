class FacilityController < ApplicationController
  def home; end

  def index
    if params[:word].present?
      @client = ::GooglePlaces::Client.new(ENV.fetch('GOOGLE_API_KEY'))
      @places = @client.spots_by_query("#{params[:word]},サウナ", language: 'ja', type: '"point_of_interest", "establishment","spa"')
      gon.places = @places
    else
      render :home
    end
  end

  private

  def facility_params
    params.require(:facility).permit(:name, :address, :image, :latitude, :longitude)
  end
end
