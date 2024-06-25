class OpeningHour < ApplicationRecord
  belongs_to :facility

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
end
