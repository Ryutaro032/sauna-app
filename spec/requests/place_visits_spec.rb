require 'rails_helper'

RSpec.describe "Placevisits", type: :request do
  describe 'POST #create' do
    context 'ユーザーがログインしているとき' do
      let(:user) { create(:user) }
      let(:facility) { create(:facility) }

      before do
        sign_in user
      end

      it 'DBにお気に入り登録できること' do
        expect do
          post place_visit_facility_path(facility), params: { id: facility.id }
        end.to change(PlaceVisit, :count).by(1)
      end

      it '詳細ページにリダイレクトされること' do
        post place_visit_facility_path(facility), params: { id: facility.id }
        expect(response).to redirect_to(facility_path(facility))
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'ユーザーがログインしているとき' do
      let(:user) { create(:user) }
      let(:facility) { create(:facility) }

      before do
        sign_in user
        create(:place_visit, user: user, facility: facility)
      end

      it 'DBからお気に入り登録が削除されること' do
        expect do
          delete place_visit_facility_path(facility)
        end.to change(PlaceVisit, :count).by(-1)
      end

      it 'ajaxリクエストの場合は詳細ページにリダイレクトされること' do
        delete place_visit_facility_path(facility), xhr: true
        expect(response).to have_http_status(:success)
        expect(response.body).to include("window.location = '#{facility_path(facility)}'")
      end

      it 'Ajaxリクエストでない場合はユーザー管理画面にリダイレクトされること' do
        delete place_visit_facility_path(facility)
        expect(response).to redirect_to(user_path(user))
      end
    end
  end
end
