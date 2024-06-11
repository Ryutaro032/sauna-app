require 'rails_helper'

RSpec.describe 'Favorites', type: :request do
  describe 'POST #create' do
    context 'ユーザーがログインしているとき' do
      let(:user) { create(:user) }
      let(:facility) { create(:facility) }

      before do
        sign_in user
      end

      it 'DBにお気に入り登録できること' do
        expect do
          post favorite_facility_path(facility), params: { id: facility.id }
        end.to change(Favorite, :count).by(1)
      end

      it '詳細ページにリダイレクトされること' do
        post favorite_facility_path(facility), params: { id: facility.id }
        expect(response).to redirect_to(facility_path(facility))
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'ユーザーがログインしているとき' do
      let(:user) { create(:user) }
      let(:facility) { create(:facility) }
      let(:favorite) { create(:favorite, user: user, facility: facility) }

      before do
        sign_in user
      end

      it 'DBからお気に入り登録が削除されること' do
        expect do
          delete favorite_facility_path(facility)
        end.to change(Favorite, :count).by(-1)
      end

      it '詳細ページにリダイレクトされること' do
        delete favorite_facility_path(facility)
        expect(response).to redirect_to(facility_path(facility))
      end
    end
  end
end
