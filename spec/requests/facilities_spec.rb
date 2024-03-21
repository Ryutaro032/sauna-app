require 'rails_helper'
require 'vcr'

RSpec.describe 'Facilities', type: :request do
  describe '#index' do
    context 'ユーザーがログインしている場合' do
      let(:user) { create(:user) }
      before { sign_in(user) }

      it 'リストページが表示されること' do
        get facility_index_path
        expect(response).to have_http_status(:ok)
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

    context 'ユーザーがログインしていない場合' do
      it 'リストページが表示されること' do
        get facility_index_path
        expect(response).to have_http_status(:ok)
      end

      it 'キーワードがない場合、トップページに戻ること' do
        get facility_index_path
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index)
        expect(flash[:notice]).to eq('キーワードを入力してください')
      end
    end
  end
end
