class FacilityController < ApplicationController
  def home
    search_places
    if @places.present?
      render :index
    else
      render :home
    end
  end

  def index
    search_places
    render :index
  end

  private

  def facility_params
    params.require(:facility).permit(:name, :address, :latitude, :longitude)
  end

  def search_places
    return if params[:word].blank?

    @client = ::GooglePlaces::Client.new(ENV.fetch('GOOGLE_API_KEY'))
    @places = @client.spots_by_query("#{params[:word]},サウナ", language: 'ja', type: '"point_of_interest", "establishment","spa"')
    gon.places = @places
    @favorites = current_user.facilities.pluck(:name) if user_signed_in?
  end
end
