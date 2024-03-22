class AddUniqueIndexToFavorites < ActiveRecord::Migration[6.0]
  def change
    add_index :favorites, [:facility_id, :user_id], unique: true
  end
end
