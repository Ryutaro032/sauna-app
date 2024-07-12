require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }

  describe 'アソシエーションについて' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:facility) }
  end

  describe 'バリデーションについて' do
    it 'タイトルがない時' do
      post = build(:post, title: nil)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include('タイトルを入力してください')
    end

    it 'タイトルが41文字以上の時' do
      post = build(:post, title: 'a' * 41)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include('タイトルは40文字以内で入力してください')
    end

    it 'レビュー内容が401文字以上の時' do
      post = build(:post, review: 'a' * 401)
      expect(post).not_to be_valid
      expect(post.errors[:review]).to include('レビュー内容は400文字以内で入力してください')
    end
  end
end
