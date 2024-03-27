require 'rails_helper'
require 'vcr'

RSpec.describe 'Facilities', type: :request do
  shared_examples 'リスト表示に関するテストについて' do
    it 'リストページが表示されること' do
      get facility_index_path
      expect(response).to have_http_status(:ok)
    end

    context 'ログインしている場合' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'Google Place APIを使用して場所を検索し、施設がお気に入りされているか確認できること' do
        VCR.use_cassette('google_places_api_request') do
          get facility_index_path, params: { word: '池袋' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('池袋')
          expect(assigns(:places)).not_to be_empty
          expect(assigns(:favorites)).to include(*user.facilities.pluck(:name))
        end
      end
    end

    context 'ログインしていない場合' do
      let(:user) { create(:user) }

      before do
        sign_out(user)
      end

      it 'Google Place APIを使用して場所を検索でき、お気に入りが表示されないこと' do
        VCR.use_cassette('google_places_api_request') do
          get facility_index_path, params: { word: '池袋' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('池袋')
          expect(assigns(:places)).not_to be_empty
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
  end

  describe '#index' do
    include_examples 'リスト表示に関するテストについて'

    it 'キーワードがない場合、リダイレクトされること' do
      get facility_index_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end
  end
end
