require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }

  describe 'アソシエーションについて' do
    it { should belong_to(:user) }
  end

  describe 'バリデーションについて' do
    it 'タイトルがない時' do
      post = build(:post, title: nil)
      expect(post).to_not be_valid
      expect(post.errors[:title]).to include("タイトルを入力してください")
    end

    it 'タイトルが41文字以上の時' do
      post = build(:post, title: 'a' * 41)
      expect(post).to_not be_valid
      expect(post.errors[:title]).to include("タイトルは40文字以内で入力してください")
    end

    it 'レビュー内容が401文字以上の時' do
      post = build(:post, review: 'a' * 401)
      expect(post).to_not be_valid
      expect(post.errors[:review]).to include("レビュー内容は400文字以内で入力してください")
    end
  end
end
