require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:user) { create(:user) }
  let(:new_post) { create(:post) }
  let(:place_name) { 'サウナ&ホテル かるまる池袋店' }
  let(:mock_client) { instance_double(GooglePlaces::Client) }
  let(:mock_place) { Struct.new(:name).new(place_name) }

  describe 'GET #new' do
    before do
      sign_in user
      allow(request).to receive(:session).and_return(user_id: user.id)
      allow(mock_client).to receive(:spot).and_return(mock_place)
      allow(GooglePlaces::Client).to receive(:new).and_return(mock_client)
    end

    it '投稿ページが表示できること' do
      get new_post_path
      expect(response).to render_template(:new)
    end

    it '@postにGoogle Places APIから施設名を格納できること' do
      get new_post_path
      expect(assigns(:post)).to be_a_new(Post).with(name: place_name)
    end
  end

  describe 'POST #create' do
    before do
      sign_in user
    end

    it '新しい投稿ができた時、トップページにリダイレクトできること' do
      post_params = attributes_for(:post)
      expect do
        post posts_path, params: { post: post_params }
      end.to change(Post, :count).by(1)

      expect(response).to redirect_to(root_path)
      expect(flash[:success]).to be_present
    end

    it '投稿ができない時、投稿ページに戻ること' do
      sign_in user
      post_params = attributes_for(:post, title: '', review: '')

      post posts_path, params: { post: post_params }

      expect(response).to render_template(:new)
    end
  end

  describe "DELETE #destroy" do
    let!(:post_to_delete) { create(:post, user: user) }

    before do
      sign_in user
    end

    it "deletes the post and redirects to the user's profile page" do
      expect do
        delete post_path(post_to_delete)
      end.to change(Post, :count).by(-1)

      expect(response).to redirect_to(user_path(user))

      expect(Post.exists?(post_to_delete.id)).to be_falsey
      expect(Post.exists?(new_post.id)).to be_truthy
    end
  end
end
