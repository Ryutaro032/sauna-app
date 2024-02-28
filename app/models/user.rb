class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :icon_image

  validates :name, presence: true, length: { maximum: 20 }
  validates :email, uniqueness: true
  validates :password, confirmation: true, length: { minimum: 6 }, allow_nil: true
  validates :password_confirmation, presence: true, allow_nil: true
  validates :my_rule, length: { maximum: 400 }

  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = 'ゲスト'
      user.id = 2
    end
  end
end