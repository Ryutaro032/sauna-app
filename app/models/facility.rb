class Facility < ApplicationRecord
  geocoded_by :address
  after_validation :geocode, if: :address_changed?
  has_many :favorites, dependent: :destroy
  has_many :users, through: :favorites

  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end
end
