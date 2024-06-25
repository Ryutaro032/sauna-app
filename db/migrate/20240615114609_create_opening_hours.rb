class CreateOpeningHours < ActiveRecord::Migration[6.1]
  def change
    create_table :opening_hours do |t|
      t.references :facility, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :opening_time
      t.time :closing_time
      t.timestamps
    end
  end
end
