require 'rails_helper'

RSpec.describe "Favorites", type: :request do
  describe "POST #create" do
    let(:user) { create(:user) }
    let(:place_id) { 'ChIJLQVdNF6NGGARR4bz6Vxdmpw' }

    before do
      sign_in user
    end

    context "お気に入り登録がされていない場合" do
      before do
        allow_any_instance_of(GooglePlaces::Client).to receive(:spot).and_return(
          double("place_details",
            name: "サウナ&ホテル かるまる池袋店",
            formatted_address: "日本、〒171-0014 東京都豊島区池袋２丁目７−７ 6F",
            lat: 35.7324069,
            lng: 139.7084296,
            place_id: place_id
          )
        )
      end

      it "お気に入り登録とDBへの保存ができること" do
        expect {
          post "/facilities/favorites", params: { place_id: place_id }
        }.to change(Facility, :count).by(1)

        expect(response).to have_http_status(:redirect)
        expect(flash[:success]).to be_present

        expect(Facility.last.name).to eq("サウナ&ホテル かるまる池袋店")
        expect(Facility.last.address).to eq("日本、〒171-0014 東京都豊島区池袋２丁目７−７ 6F")
        expect(user.favorites.last.facility).to eq(Facility.last)
      end
    end

    context "お気に入り登録がされている場合" do
      before do
        facility = create(:facility, name: "サウナ&ホテル かるまる池袋店")
        user.favorites.create(facility: facility)
      end

      it "お気に入り登録ができないこと" do
        expect {
          post "/facilities/favorites", params: { place_id: place_id }
        }.not_to change(Facility, :count)

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'DELETE #destroy' do
  let(:user) { create(:user) }
  let(:facility) { create(:facility) }

  before do
    sign_in user
  end

  context 'お気に入り登録をしている施設の場合' do
    before do
      user.favorites.create(facility: facility)
    end

    it 'お気に入り登録を削除できること' do
      expect {
        delete "/facilities/favorites", params: { place_id: facility.place_id }
      }.to change { user.favorites.count }.by(-1)

      expect(response).to redirect_to(root_path)
    end

    it 'メッセージが表示できること' do
      delete "/facilities/favorites", params: { place_id: facility.place_id }
      expect(flash[:success]).to eq('お気に入りから削除しました')
    end
  end

  context 'お気に入り登録をしていない施設の場合' do
    it 'お気に入り登録がされていないこと' do
      allow(Facility).to receive(:find_by).and_return(nil)
      expect {
        delete "/facilities/favorites", params: { place_id: 'non_existing_place_id' }
      }.not_to change { user.favorites.count }

      expect(flash[:success]).to be_nil
    end
  end
end
end
