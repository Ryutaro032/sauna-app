require 'rails_helper'

RSpec.describe "ReviewLikes", type: :request do
  let!(:user) { create(:user) }
  let!(:new_post) { create(:post, user: user) }
  
  before do
    sign_in user
  end

  describe "POST /create" do
    it "review likeが作成され、カウントが+1されること" do
      expect {
        post post_review_like_path(new_post), params: { post_id: new_post.id }, xhr: true
      }.to change(ReviewLike, :count).by(1)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /destroy" do
    let!(:review_like) { create(:review_like, user: user, post: new_post) }

    it "review likeが削除され、カウントが-1されること" do
      expect {
        delete post_review_like_path(post_id: new_post.id), xhr: true
      }.to change(ReviewLike, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end
end
