class Tasks < ActiveRecord::Migration[6.1]
  def change
    drop_table :Favorites
  end
end
