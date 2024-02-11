require 'rails_helper'

RSpec.describe 'Facilities', type: :request do
  describe '#index' do
    it 'リストページが表示されること' do
      get facility_index_path
      expect(response).to have_http_status(:ok)
    end

    context 'キーワードがある場合' do
      it 'Google Place APIを使用して場所を検索すること' do
        VCR.use_cassette('google_places_api_request') do
          get facility_index_path, params: { word: '池袋' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('池袋1')
        end
      end
    end

    context 'キーワードがない場合' do
      it 'トップページに戻ること' do
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:home)
      end
    end
  end
end
