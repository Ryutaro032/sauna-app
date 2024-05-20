require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user) { create(:user) }
  let(:new_post) { create(:post) }

  describe "GET #new" do
    before do
      sign_in user
      client = instance_double(GooglePlaces::Client)
      allow(GooglePlaces::Client).to receive(:new).and_return(client)
      allow(client).to receive(:spot).and_return(
        instance_double(
          'place_details',
          name: 'サウナ&ホテル かるまる池袋店',
        )
      )
    end

    it "投稿ページが表示できること" do
      get new_post_path
      expect(response).to render_template(:new)
    end

    it "@postにGoogle Places APIから施設名を格納できること" do
      place_name = 'サウナ&ホテル かるまる池袋店'
      allow_any_instance_of(::GooglePlaces::Client).to receive(:spot).and_return(double(name: place_name))

      get new_post_path
      expect(assigns(:post)).to be_a_new(Post).with(name: place_name)
    end
  end

  describe "POST #create" do
    before do
      sign_in user
    end

    it "新しい投稿ができた時、トップページにリダイレクトできること" do
      post_params = attributes_for(:post)
      expect {
        post posts_path, params: { post: post_params }
      }.to change(Post, :count).by(1)

      expect(response).to redirect_to(root_path)
      expect(flash[:success]).to be_present
    end
    
    it "投稿ができない時、投稿ページに戻ること" do
      sign_in user
      post_params = attributes_for(:post, title: "", review: "")

      post posts_path, params: { post: post_params }

      expect(response).to render_template(:new)
      expect(flash[:error]).to be_present
    end
  end
end
