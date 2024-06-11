class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    facility = Facility.find(params[:id])
    current_user.favorites.create(facility: facility)
    flash[:success] = I18n.t('flash.favorite.create.success')
    respond_to do |format|
      format.html { redirect_to facility_path(facility) }
      format.js
    end
  end

  def destroy
    facility = Facility.find(params[:id])
    current_user.favorites.find_by(facility: facility).destroy
    flash[:success] = I18n.t('flash.favorite.destroy.success')
    respond_to do |format|
      format.html { redirect_to facility_path(facility) }
      format.js
    end
  end
end
