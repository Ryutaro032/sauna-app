class FacilitiesController < ApplicationController
  before_action :authenticate_user!, only: %i[edit update]

  def home
    @posts = Post.order(created_at: :desc).limit(20)
    
    if search_places
      render :index
    elsif filter_params.present?
      @facilities = Facility.conditional_search(filter_params)
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
    @facility_reviews = @facility.posts.order(created_at: :desc).limit(20)
  end

  def edit
    @facility = Facility.find_by(id: params[:id])
  end

  def update
    @facility = Facility.find_by(id: params[:id])
    if @facility.update(facility_params)
      redirect_to facility_path(@facility)
      flash[:success] = I18n.t('flash.facility.edit.success')
    else
      render :edit
    end
  end

  private

  def facility_params
    params.require(:facility).permit(
      :name, :address, :latitude, :longitude, :facility_icon, :min_price, :max_price,
      :free_text, :outdoor_bath, :rest_area, :aufguss, :auto_louver, :self_louver, :sauna_mat,
      :bath_towel, :face_towel, :in_house_wear, :work_space, :in_house_rest_area, :restaurant,
      :wifi, :comics, opening_hours_attributes: %i[id day_of_week opening_time closing_time holiday _destroy]
    )
  end

  def search_places
    @places = Facility.search_places(params)
    @save_places = Facility.search_places_and_save(params)
  end
  
  def filter_params
    params.permit(
      :prefecture_id, :city_id, :word, :sauna_mat, :bath_towel, :face_towel, :in_house_wear,
      :outdoor_bath, :rest_area, :aufguss, :auto_louver, :self_louver, :work_space,
      :in_house_rest_area, :restaurant, :wifi, :comics
    ).to_h.reject { |k, v| v == "0" }
  end
end
