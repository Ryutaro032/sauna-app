require 'rails_helper'

RSpec.describe "Posts", :js, type: :system do
  let(:user) { create(:user) }
  let(:post) { create(:post) }

  before do
    sign_in user
    allow_any_instance_of(GooglePlaces::Client).to receive(:spot).and_return(
      OpenStruct.new(name: post.name)
    )
  end

  context '投稿が成功する場合' do
    it "allows a user to create a new post" do
      visit new_post_path
  
      expect(page).to have_content("レビューを投稿する")
  
      fill_in "タイトル", with: post.title
      fill_in "レビュー内容", with: post.review
  
      click_button "投稿する"
  
      expect(current_path).to eq(root_path)
      expect(page).to have_content('レビューを投稿しました')
      expect(Post.last.title).to eq(post.title)
      expect(Post.last.review).to eq(post.review)
      expect(Post.last.name).to eq(post.name)
    end
  end
  
  context '投稿が失敗する場合'do
    it "タイトルが40文字以上の時、エラーメッセージが出ること" do
      visit new_post_path

      fill_in "タイトル", with: "a" * 41
      fill_in "レビュー内容", with: post.review

      click_button "投稿する"

      expect(page).to have_content("タイトルは40文字以内で入力してください")
    end

    it "タイトルがない時、エラーメッセージが出ること" do
      visit new_post_path

      fill_in "タイトル", with: ""
      fill_in "レビュー内容", with: post.review

      click_button "投稿する"

      expect(page).to have_content("タイトルを入力してください")
    end

    it "レビュー内容が401文字以上の時、エラーメッセージが出ること" do
      visit new_post_path

      fill_in "タイトル", with: post.title
      fill_in "レビュー内容", with: "a" * 401

      click_button "投稿する"

      expect(page).to have_content("レビュー内容は400文字以内で入力してください")
    end
  end
end
