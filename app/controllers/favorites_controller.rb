class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    place_id = params[:place_id]
    @client = ::GooglePlaces::Client.new(ENV.fetch('GOOGLE_API_KEY'))
    place_details = @client.spot(place_id, language: 'ja')
    existing_favorite = current_user.facilities.find_by(name: place_details.name)
    if existing_favorite

    else
      @facility = Facility.new(
        name: place_details.name,
        address: place_details.formatted_address,
        latitude: place_details.lat,
        longitude: place_details.lng,
        place_id: place_details.place_id
      )

      if @facility.save
        @facilities = Facility.all
        @favorite = current_user.favorites.create(facility: @facility)
        gon.places = @facilities
        flash[:success] = I18n.t('flash.create.success')
        redirect_back fallback_location: root_path
      end
    end
  end

  def destroy
    @facility = Facility.find_by(place_id: params[:place_id])
    @favorite = current_user.favorites.find_by(facility: @facility)

    return if @favorite.nil?

    return unless @favorite.destroy

    flash[:success] = I18n.t('flash.destroy.success')
    redirect_back fallback_location: root_path
  end
end
