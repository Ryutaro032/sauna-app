require 'rails_helper'

RSpec.describe 'Posts', :js, type: :system do
  let(:user) { create(:user) }
  let(:facility) { create(:facility) }
  let(:post) { build(:post, user: user, facility: facility) }

  before do
    sign_in user
  end

  context '投稿が成功する場合' do
    it 'ログインユーザーの投稿ができること' do
      visit new_post_path(facility_id: facility.id)

      expect(page).to have_content('レビューを投稿する')

      fill_in 'タイトル', with: post.title
      fill_in 'レビュー内容', with: post.review

      click_on '投稿する'

      expect(page).to have_current_path(root_path)
      expect(page).to have_content('レビューを投稿しました')
      expect(Post.last.title).to eq(post.title)
      expect(Post.last.review).to eq(post.review)
    end
  end

  context '投稿が失敗する場合' do
    it 'タイトルが40文字以上の時、エラーメッセージが出ること' do
      visit new_post_path(facility_id: facility.id)

      fill_in 'タイトル', with: 'a' * 41
      fill_in 'レビュー内容', with: post.review

      click_on '投稿する'

      expect(page).to have_content('タイトルは40文字以内で入力してください')
    end

    it 'タイトルがない時、エラーメッセージが出ること' do
      visit new_post_path(facility_id: facility.id)

      fill_in 'タイトル', with: ''
      fill_in 'レビュー内容', with: post.review

      click_on '投稿する'

      expect(page).to have_content('タイトルを入力してください')
    end

    it 'レビュー内容が20文字未満もしくは401文字以上の時、エラーメッセージが出ること' do
      visit new_post_path(facility_id: facility.id)

      fill_in 'タイトル', with: post.title
      fill_in 'レビュー内容', with: 'a' * 19

      click_on '投稿する'

      expect(page).to have_content('レビュー内容は20文字以上400文字以内で入力してください')

      fill_in 'タイトル', with: post.title
      fill_in 'レビュー内容', with: 'a' * 401

      click_on '投稿する'

      expect(page).to have_content('レビュー内容は20文字以上400文字以内で入力してください')
    end
  end
end
