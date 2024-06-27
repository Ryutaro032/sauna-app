class AddHolidayToOpeningHours < ActiveRecord::Migration[6.1]
  def change
    add_column :opening_hours, :holiday, :boolean
  end
end
