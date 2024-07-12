class AddFacilityIdToPosts < ActiveRecord::Migration[6.1]
  def change
    add_reference :posts, :facility, foreign_key: true
  end
end
