class Post < ApplicationRecord
  belongs_to :user
  belongs_to :facility
  has_many :review_likes, dependent: :destroy

  validates :title, presence: { message: I18n.t('activerecord.errors.models.post.attributes.title.blank') },
                    length: { maximum: 40, message: I18n.t('activerecord.errors.models.post.attributes.title.too_long') }
  validates :review, length: { minimum: 20, maximum: 400, message: I18n.t('activerecord.errors.models.post.attributes.review.too_long') }
end
