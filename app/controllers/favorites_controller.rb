class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @facility = Facility.find_by(place_id: params[:facility][:place_id])

    return unless user_signed_in?

    if @facility
      current_user.favorite_facilities << @facility
      flash[:success] = I18n.t('flash.favorite.create.success')
    else
      flash[:error] = "Failed to add to favorites"
    end

    redirect_to facility_path(params[:id])
  end

  def destroy
    @facility = Facility.find_by(id: params[:id])
  
    return unless user_signed_in?
  
    if @facility && current_user.favorite_facilities.include?(@facility)
      current_user.favorite_facilities.delete(@facility)
      flash[:success] = I18n.t('flash.favorite.destroy.success')
    else
      flash[:error] = "Failed to remove from favorites"
    end
  
    redirect_to facility_path(@facility.place_id, name: @facility.name, address: @facility.address, latitude: @facility.latitude, longitude: @facility.longitude)
  end
end
