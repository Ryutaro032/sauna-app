require 'rails_helper'

RSpec.describe Facility, type: :model do
  let(:user) { create(:user) }
  let(:facility) { create(:facility) }
  let(:prefecture) { create(:prefecture) }
  let(:city) { prefecture.cities.first }

  it { should have_many(:favorites).dependent(:destroy) }
  it { should have_many(:users).through(:favorites) }

  describe 'geocodingについて' do
    let(:facility) { Facility.new(address: '東京都, 日本') }

    it '住所が変更された場合' do
      expect(facility).to receive(:geocode)
      facility.valid?
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
        OpenStruct.new(
          name: 'サウナ1',
          formatted_address: '東京都千代田区丸の内1-1',
          lat: 35.6812,
          lng: 139.7671,
          place_id: 'place1'
        ),
        OpenStruct.new(
          name: 'サウナ2',
          formatted_address: '東京都千代田区丸の内2-2',
          lat: 35.6822,
          lng: 139.7691,
          place_id: 'place2'
        )
      ]
    end

    before do
      allow(Facility).to receive(:search_places).with(params).and_return(place_data)
    end

    context '場所がまだ保存されていない場合' do
      it '新しい場所をデータベースに保存する' do
        expect {
          Facility.search_places_and_save(params)
        }.to change(Facility, :count).by(2)

        place_data.each do |place|
          expect(Facility.find_by(place_id: place.place_id)).not_to be_nil
        end
      end
    end

    context '場所が既に保存されている場合' do
      before do
        place_data.each do |place|
          Facility.create(
            name: place.name,
            address: place.formatted_address,
            latitude: place.lat,
            longitude: place.lng,
            place_id: place.place_id
          )
        end
      end

      it '重複する場所をデータベースに保存しない' do
        expect {
          Facility.search_places_and_save(params)
        }.not_to change(Facility, :count)
      end
    end

    context '検索で場所が返されない場合' do
      before do
        allow(Facility).to receive(:search_places).with(params).and_return([])
      end

      it 'データベースに変更を加えない' do
        expect {
          Facility.search_places_and_save(params)
        }.not_to change(Facility, :count)
      end
    end
  end
end
