require 'rails_helper'
require 'vcr'

RSpec.describe 'Facilities', type: :request do
  shared_examples 'リスト表示に関するテストについて' do
    let(:prefecture) { create(:prefecture) }
    let(:city) { prefecture.cities.first }
    let(:posts) { (1..25).map { create(:post) } }

    it 'リストページが表示されること' do
      get facilities_index_path
      expect(response).to have_http_status(:ok)
    end

    context 'ログインしている場合' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'Google Place APIを使用して場所を検索し、施設がお気に入りされているか確認できること' do
        VCR.use_cassette('google_api_search') do
          get facilities_index_path, params: { word: '池袋' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('池袋')
          expect(assigns(:favorites)).to include(*user.facilities.pluck(:name))
        end
      end

      it '都道府県と市区町村で検索し、施設がお気に入りされているか確認できること' do
        VCR.use_cassette('google_api_search') do
          params = { prefecture_id: prefecture.id, city_id: city.id }
          get facilities_index_path, params: params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(prefecture.name)
          expect(response.body).to include(city.name)
          expect(assigns(:favorites)).to include(*user.facilities.pluck(:name))
        end
      end
    end

    context 'ログインしていない場合' do
      let(:user) { create(:user) }

      before do
        sign_out(user)
      end

      it 'キーワードで場所を検索でき、お気に入りが表示されないこと' do
        VCR.use_cassette('google_api_search') do
          get facilities_index_path, params: { word: '池袋' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('池袋')
          expect(assigns(:favorites)).to be_nil
        end
      end

      it '都道府県と市区町村で検索でき、施設がお気に入りが表示されないこと' do
        VCR.use_cassette('google_api_search') do
          params = { prefecture_id: prefecture.id, city_id: city.id }
          get facilities_index_path, params: params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(prefecture.name)
          expect(response.body).to include(city.name)
          expect(assigns(:favorites)).to be_nil
        end
      end
    end
  end

  describe '#home' do
    include_examples 'リスト表示に関するテストについて'

    it 'キーワードがない場合、トップページに戻ること' do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:home)
    end

    it '投稿が20件表示されること' do
      get root_path

      Post.order(created_at: :desc).limit(20).each do |post|
        expect(response.body).to include(post.title)
        expect(response.body).to include(post.review)
        expect(response.body).to include('user-icon')
        expect(assigns(:posts).count).to be <= 20
      end
    end
  end

  describe '#index' do
    include_examples 'リスト表示に関するテストについて'

    it 'キーワードがない場合、リダイレクトされること' do
      get facilities_index_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end
  end
end
