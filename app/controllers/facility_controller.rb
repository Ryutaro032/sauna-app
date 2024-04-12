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
    @places = Facility.search_places(params)
    gon.places = @places if @places.present?
    @favorites = current_user.facilities.pluck(:name) if user_signed_in?
  end
end
