class AddPlaceIdToFacility < ActiveRecord::Migration[6.1]
  def change
    add_column :facilities, :place_id, :string
  end
end
