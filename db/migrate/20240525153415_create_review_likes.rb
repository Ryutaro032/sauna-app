class CreateReviewLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :review_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
  end
end
