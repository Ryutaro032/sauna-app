class PlaceVisitsController < ApplicationController
  before_action :authenticate_user!

  def create
    facility = Facility.find(params[:id])
    current_user.place_visits.create(facility: facility)
    flash[:success] = I18n.t('flash.place_visit.create.success')
    respond_to do |format|
      format.html { redirect_to facility_path(facility) }
      format.js
    end
  end

  def destroy
    facility = Facility.find(params[:id])
    place_visit = current_user.place_visits.find_by(facility: facility)

    if place_visit
      @facility = place_visit.facility
      place_visit.destroy
      flash[:success] = I18n.t('flash.place_visit.destroy.success')
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
