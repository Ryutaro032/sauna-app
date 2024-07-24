require 'rails_helper'

Place = Struct.new(:name, :formatted_address, :lat, :lng, :place_id)

RSpec.describe Facility, type: :model do
  let(:user) { create(:user) }
  let(:facility) { create(:facility) }
  let(:prefecture) { create(:prefecture) }
  let(:city) { prefecture.cities.first }

  it { is_expected.to have_many(:favorites).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:favorites) }
  it { is_expected.to have_many(:posts) }
  it { is_expected.to have_many(:opening_hours).dependent(:destroy) }

  describe 'バリデーションについて' do
    context 'max_price_greater_than_min_price' do
      it 'max_priceがmin_priceよりも大きい場合、エラーが発生しないこと' do
        facility.min_price = 1000
        facility.max_price = 2000
        expect(facility).to be_valid
        expect(facility.errors[:base]).not_to include('正しい料金を入れてください')
      end

      it 'max_priceがmin_price以下の場合、エラーが発生すること' do
        facility.min_price = 2000
        facility.max_price = 1000
        facility.valid?
        expect(facility.errors[:base]).to include('正しい料金を入れてください')
      end

      it 'max_priceがnilの場合、エラーが発生しないこと' do
        facility.max_price = nil
        expect(facility).to be_valid
        expect(facility.errors[:base]).not_to include('正しい料金を入れてください')
      end

      it 'min_priceがnilの場合、エラーが発生しないこと' do
        facility.min_price = nil
        expect(facility).to be_valid
        expect(facility.errors[:base]).not_to include('正しい料金を入れてください')
      end
    end

    context '金額が0以下の場合のバリデーションについて' do
      it 'min_priceが0以下の場合、エラーが発生すること' do
        facility = described_class.new(min_price: -1)
        expect(facility).not_to be_valid
        expect(facility.errors[:min_price]).to include('金額は0以上の値にしてください')
      end

      it 'max_priceが0以下の場合、エラーが発生すること' do
        facility = described_class.new(max_price: -1)
        expect(facility).not_to be_valid
        expect(facility.errors[:max_price]).to include('金額は0以上の値にしてください')
      end

      it 'min_priceとmax_priceが0の場合、エラーが発生しないこと' do
        facility = described_class.new(min_price: 0, max_price: 0)
        expect(facility).to be_valid
      end
    end

    context 'closing_time_after_opening_time' do
      it 'closing_timeがopening_timeより時間が前の場合、エラーが発生すること' do
        opening_hour = OpeningHour.new(day_of_week: 1, opening_time: '17:00', closing_time: '09:00')
        facility = described_class.new(opening_hours: [opening_hour])
        expect(facility).not_to be_valid
        expect(facility.errors[:base]).to include('閉店時間は開店時間より後の時間に設定してください')
      end

      it 'closing_timeがopening_timeより時間が後の場合、エラーが発生しないこと' do
        opening_hour = OpeningHour.new(day_of_week: 1, opening_time: '09:00', closing_time: '17:00')
        facility = described_class.new(opening_hours: [opening_hour])
        expect(facility).to be_valid
      end

      it 'holidayが選択された場合、バリデーションがスルーされること' do
        opening_hour = OpeningHour.new(day_of_week: 1, opening_time: nil, closing_time: nil, holiday: true)
        facility = described_class.new(opening_hours: [opening_hour])
        expect(facility).to be_valid
      end
    end

    context 'free_textのバリデーションについて' do
      let(:long_text) { 'a' * 1201 }
      let(:short_text) { 'a' * 1200 }

      it '1201文字以上の場合、エラーが発生すること' do
        facility = described_class.new(free_text: long_text)
        expect(facility).not_to be_valid
        expect(facility.errors[:free_text]).to include('1200文字以内で入力してください')
      end

      it '1200文字以内の場合、エラーが発生しないこと' do
        facility = described_class.new(free_text: short_text)
        expect(facility).to be_valid
      end
    end
  end

  describe '#favorited_by?' do
    context 'ユーザーがお気に入り登録をしようとした時' do
      it 'お気に入りしていない時' do
        favorite = create(:favorite, user: user, facility: facility)
        facility = favorite.facility
        expect(facility.favorited_by?(user)).to be true
      end

      it 'お気に入りしている時' do
        facility = create(:facility)
        expect(facility.favorited_by?(user)).to be false
      end
    end
  end

  describe 'self.search_places' do
    context '都道府県と市区町村が存在する場合' do
      it '都道府県と市区町村で検索できること' do
        params = { prefecture_id: prefecture.id, city_id: city.id }

        VCR.use_cassette('google_api_search') do
          expect(described_class.search_places(params)).to be_a(Array)
        end
      end
    end

    context '都道府県のみ存在する場合' do
      it '都道府県で検索できること' do
        params = { prefecture_id: prefecture.id }

        VCR.use_cassette('google_api_search') do
          expect(described_class.search_places(params)).to be_a(Array)
        end
      end
    end

    context 'キーワードが存在する場合' do
      it 'キーワードで検索できること' do
        params = { word: '池袋' }

        VCR.use_cassette('google_api_search') do
          expect(described_class.search_places(params)).to be_a(Array)
        end
      end
    end

    context 'パラメータが存在しない場合' do
      it 'nilを返すこと' do
        params = {}

        expect(described_class.search_places(params)).to be_nil
      end
    end
  end

  describe '.search_places_and_save' do
    let(:params) { { query: 'サウナ', location: '東京' } }

    let(:place_data) do
      [
        Place.new('サウナ1', '東京都千代田区丸の内1-1', 35.6812, 139.7671, 'place1'),
        Place.new('サウナ2', '東京都千代田区丸の内2-2', 35.6822, 139.7691, 'place2')
      ]
    end

    before do
      allow(described_class).to receive(:search_places).with(params).and_return(place_data)
    end

    context '場所がまだ保存されていない場合' do
      it '新しい場所をデータベースに保存する' do
        expect do
          described_class.search_places_and_save(params)
        end.to change(described_class, :count).by(2)

        place_data.each do |place|
          expect(described_class.find_by(place_id: place.place_id)).not_to be_nil
        end
      end
    end

    context '場所が既に保存されている場合' do
      before do
        place_data.each do |place|
          described_class.create(
            name: place.name,
            address: place.formatted_address,
            latitude: place.lat,
            longitude: place.lng,
            place_id: place.place_id
          )
        end
      end

      it '重複する場所をデータベースに保存しない' do
        expect do
          described_class.search_places_and_save(params)
        end.not_to change(described_class, :count)
      end
    end

    context '検索で場所が返されない場合' do
      before do
        allow(described_class).to receive(:search_places).with(params).and_return([])
      end

      it 'データベースに変更を加えない' do
        expect do
          described_class.search_places_and_save(params)
        end.not_to change(described_class, :count)
      end
    end
  end

  describe 'self.conditional_search' do
    let(:facility_boolean) { create(:facility, outdoor_bath: true, rest_area: true, aufguss: true, auto_louver: true, self_louver: true) }
    let(:facility_select) { create(:facility, sauna_mat: '無料（使い放題）', bath_towel: '無料（使い放題）', face_towel: '無料（使い放題）', in_house_wear: '無料（使い放題）') }
    let(:facility_boolean2) { create(:facility, work_space: true, in_house_rest_area: true, restaurant: true, wifi: true, comics: true) }

    it 'outdoor_bathの真偽値が取得できること' do
      params = { outdoor_bath: '1' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_boolean)
      expect(results).not_to include(facility)
    end

    it 'rest_areaの真偽値が取得できること' do
      params = { rest_area: '1' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_boolean)
      expect(results).not_to include(facility)
    end

    it 'aufgussの真偽値が取得できること' do
      params = { aufguss: '1' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_boolean)
      expect(results).not_to include(facility)
    end

    it 'auto_louverの真偽値が取得できること' do
      params = { auto_louver: '1' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_boolean)
      expect(results).not_to include(facility)
    end

    it 'self_louverの真偽値が取得できること' do
      params = { self_louver: '1' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_boolean)
      expect(results).not_to include(facility)
    end

    it 'sauna_matの値が取得できること' do
      params = { sauna_mat: '無料（使い放題）' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_select)
      expect(results).not_to include(facility)
    end

    it 'bath_towelの値が取得できること' do
      params = { bath_towel: '無料（使い放題）' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_select)
      expect(results).not_to include(facility)
    end

    it 'face_towelの値が取得できること' do
      params = { face_towel: '無料（使い放題）' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_select)
      expect(results).not_to include(facility)
    end

    it 'in_house_wearの値が取得できること' do
      params = { in_house_wear: '無料（使い放題）' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_select)
      expect(results).not_to include(facility)
    end

    it 'work_spaceの真偽値が取得できること' do
      params = { work_space: '1' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_boolean2)
      expect(results).not_to include(facility)
    end

    it 'in_house_rest_areaの真偽値が取得できること' do
      params = { in_house_rest_area: '1' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_boolean2)
      expect(results).not_to include(facility)
    end

    it 'restaurantの真偽値が取得できること' do
      params = { restaurant: '1' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_boolean2)
      expect(results).not_to include(facility)
    end

    it 'wifiの真偽値が取得できること' do
      params = { wifi: '1' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_boolean2)
      expect(results).not_to include(facility)
    end

    it 'comicsの真偽値が取得できること' do
      params = { comics: '1' }
      results = described_class.conditional_search(params)
      expect(results).to include(facility_boolean2)
      expect(results).not_to include(facility)
    end
  end
end
