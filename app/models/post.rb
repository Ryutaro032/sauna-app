class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: { message: I18n.t('activerecord.errors.models.post.attributes.title.blank') },
                    length: { maximum: 40, message: I18n.t('activerecord.errors.models.post.attributes.title.too_long') }
  validates :review, length: { maximum: 400, message: I18n.t('activerecord.errors.models.post.attributes.review.too_long') }
end
