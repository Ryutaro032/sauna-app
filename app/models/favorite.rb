class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :facility, dependent: :destroy
  validates :facility_id, uniqueness: { scope: :user_id }
end
