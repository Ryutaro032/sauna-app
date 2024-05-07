require 'rails_helper'

RSpec.describe Facility, type: :model do
  let(:user) { create(:user) }
  let(:facility) { create(:facility) }
  let(:prefecture) { create(:prefecture) }
  let(:city) { prefecture.cities.first }

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
        # params = { prefecture: prefecture.id, city: city.id }
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

        VCR.use_cassette('google_places_search') do
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
end
