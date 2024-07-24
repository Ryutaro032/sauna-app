module FacilityConditionalSearch
  extend ActiveSupport::Concern

  class_methods do
    def conditional_search(params)
      facilities = Facility.all

      facilities = facilities.where(outdoor_bath: true) if params[:outdoor_bath] == '1'
      facilities = facilities.where(rest_area: true) if params[:rest_area] == '1'
      facilities = facilities.where(aufguss: true) if params[:aufguss] == '1'
      facilities = facilities.where(auto_louver: true) if params[:auto_louver] == '1'
      facilities = facilities.where(self_louver: true) if params[:self_louver] == '1'
      facilities = facilities.where(sauna_mat: params[:sauna_mat]) if params[:sauna_mat].present?
      facilities = facilities.where(bath_towel: params[:bath_towel]) if params[:bath_towel].present?
      facilities = facilities.where(face_towel: params[:face_towel]) if params[:face_towel].present?
      facilities = facilities.where(in_house_wear: params[:in_house_wear]) if params[:in_house_wear].present?
      facilities = facilities.where(work_space: true) if params[:work_space] == '1'
      facilities = facilities.where(in_house_rest_area: true) if params[:in_house_rest_area] == '1'
      facilities = facilities.where(restaurant: true) if params[:restaurant] == '1'
      facilities = facilities.where(wifi: true) if params[:wifi] == '1'
      facilities = facilities.where(comics: true) if params[:comics] == '1'

      facilities
    end
  end
end
