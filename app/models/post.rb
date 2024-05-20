class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: { message: "タイトルを入力してください" }, 
            length: { maximum: 40, message: "タイトルは40文字以内で入力してください" }
  
  validates :review, length: { maximum: 400, message: "レビュー内容は400文字以内で入力してください" }
end
