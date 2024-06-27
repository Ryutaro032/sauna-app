class CreatePlaceVisits < ActiveRecord::Migration[6.1]
  def change
    create_table :place_visits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :facility, null: false, foreign_key: true
      t.timestamps
    end
    add_index :place_visits, [:user_id, :facility_id], unique: true
  end
end
