class CreatePrefectures < ActiveRecord::Migration[6.1]
  def change
    create_table :prefectures do |t|
      t.string :name
      t.timestamps
    end
    
    add_index :prefectures, :name, unique: true
  end
end
