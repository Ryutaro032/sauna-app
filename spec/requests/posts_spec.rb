require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:user) { create(:user) }
  let(:facility) { create(:facility) }

  describe 'GET #new' do
    before do
      sign_in user
    end

    it '投稿ページが表示できること' do 
      get new_post_path(facility_id: facility.id)
      expect(response).to render_template(:new)
    end

    it "postインスタンスが作成されること" do
      get new_post_path(facility_id: facility.id)
      expect(assigns(:post)).to be_a_new(Post).with(facility_id: facility.id)
    end
  end

  describe 'POST #create' do
    before do
      sign_in user
    end

    it '新しい投稿ができた時、トップページにリダイレクトできること' do
      post_params = attributes_for(:post, user_id: user.id, facility_id: facility.id)
      expect do
        post posts_path, params: { post: post_params }
      end.to change(Post, :count).by(1)

      expect(response).to redirect_to(root_path)
      expect(flash[:success]).to be_present
      expect(Post.last.title).to eq(post_params[:title])
      expect(Post.last.review).to eq(post_params[:review])
      expect(Post.last.user).to eq(user)
      expect(Post.last.name).to eq(facility.name)
    end

    it '投稿ができない時、投稿ページに戻ること' do
      post_params = attributes_for(:post, title: "", review: "", user_id: user.id, facility_id: facility.id)
      expect do
        post posts_path, params: { post: post_params }
      end.to change(Post, :count).by(0)

      expect(response).to render_template(:new)
    end
  end

  describe '#destroy' do
    let(:new_post) { create(:post) }
    let!(:post_to_delete) { create(:post, user: user) }

    before do
      sign_in user
    end

    it '自身の投稿が削除でき、ユーザーページにリダイレクトできること' do
      expect do
        delete post_path(post_to_delete)
      end.to change(Post, :count).by(-1)

      expect(response).to redirect_to(user_path(user))

      expect(Post.where(id: post_to_delete.id)).not_to exist
      expect(Post.where(id: new_post.id)).to exist
    end
  end
end
