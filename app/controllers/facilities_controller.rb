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
    place_details
    @facility = Facility.find_by(name: @place_details.name, address: @place_details.formatted_address)

    if @facility.nil?
      @facility = Facility.create(
        name: @place_details.name,
        address: @place_details.formatted_address,
        latitude: @place_details.lat,
        longitude: @place_details.lng,
        place_id: @place_details.place_id
      )
    end
  end

  private

  def facility_params
    params.require(:facility).permit(:name, :address, :latitude, :longitude)
  end

  def search_places
    @places = Facility.search_places(params)
    gon.places = @places if @places.present?
    # @favorites = current_user.facilities.pluck(:name) if user_signed_in?
    # @visited_places = current_user.visited_places.pluck(:name) if user_signed_in?
  end

  def place_details
    place_id = params[:id]
    @client = ::GooglePlaces::Client.new(ENV.fetch('GOOGLE_API_KEY'))
    @place_details = @client.spot(place_id, language: 'ja')
  end
end
