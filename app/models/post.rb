class Post < ApplicationRecord
  belongs_to :user
  
  validates :title, presence: true, length: { maximum: 40 }
  validates :review, length: { maximum: 400 }
end
