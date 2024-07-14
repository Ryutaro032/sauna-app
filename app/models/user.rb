class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :icon_image

  has_many :favorites, dependent: :destroy
  has_many :favorite_facilities, through: :favorites, source: :facility
  has_many :facilities, through: :favorites
  has_many :posts, dependent: :destroy
  has_many :place_visit_facilities, through: :place_visits, source: :facility
  has_many :place_visits, dependent: :destroy
  has_many :review_likes, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }
  validates :email, uniqueness: true
  validates :password, confirmation: true, length: { minimum: 6 }, allow_nil: true
  validates :password_confirmation, presence: true, allow_nil: true
  validates :my_rule, length: { maximum: 400 }

  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = 'ゲスト'
      user.id = 1
      user.icon_image.attach(io: File.open(Rails.root.join('app/assets/images/guest_icon.png')), filename: 'guest_icon.png') 
    end
  end
end
