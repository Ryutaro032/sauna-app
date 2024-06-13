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
    favorite = current_user.favorites.find_by(facility: facility)

    if favorite
      @facility = favorite.facility
      favorite.destroy
      flash.now[:success] = I18n.t('flash.favorite.destroy.success')
    end
    respond_to do |format|
      format.html do
        if request.xhr?
          render js: "window.location = '#{facility_path(@facility)}';"
        else
          redirect_back fallback_location: user_path(current_user)
        end
      end
      format.js
    end
  end
end
