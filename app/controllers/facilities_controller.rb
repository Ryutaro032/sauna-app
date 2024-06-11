class FacilitiesController < ApplicationController
  def home
    @posts = Post.order(created_at: :desc).limit(20)
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

  def show
    @facility = Facility.find_by(id: params[:id])
  end

  private

  def facility_params
    params.require(:facility).permit(:name, :address, :latitude, :longitude)
  end

  def search_places
    @places = Facility.search_places(params)
    @save_places = Facility.search_places_and_save(params)
    gon.places = @places if @places.present?
  end
end
