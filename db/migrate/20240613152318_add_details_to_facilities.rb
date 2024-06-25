class AddDetailsToFacilities < ActiveRecord::Migration[6.1]
  def change
    add_column :facilities, :facility_icon, :string
    add_column :facilities, :min_price, :integer
    add_column :facilities, :max_price, :integer
    add_column :facilities, :free_text, :text
    add_column :facilities, :outdoor_bath, :boolean
    add_column :facilities, :rest_area, :boolean
    add_column :facilities, :aufguss, :boolean
    add_column :facilities, :auto_louver, :boolean
    add_column :facilities, :self_louver, :boolean
    add_column :facilities, :sauna_mat, :string
    add_column :facilities, :bath_towel, :string
    add_column :facilities, :face_towel, :string
    add_column :facilities, :in_house_wear, :string
    add_column :facilities, :work_space, :boolean
    add_column :facilities, :in_house_rest_area, :boolean
    add_column :facilities, :restaurant, :boolean
    add_column :facilities, :wifi, :boolean
    add_column :facilities, :comics, :boolean
  end
end
