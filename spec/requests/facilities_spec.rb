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

      it 'Google Place APIを使用して場所を検索できること' do
        VCR.use_cassette('google_api_search') do
          get facilities_index_path, params: { word: '池袋' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('池袋')
        end
      end

      it '都道府県と市区町村で検索できること' do
        VCR.use_cassette('google_api_search') do
          params = { prefecture_id: prefecture.id, city_id: city.id }
          get facilities_index_path, params: params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(prefecture.name)
          expect(response.body).to include(city.name)
        end
      end
    end

    context 'ログインしていない場合' do
      let(:user) { create(:user) }

      before do
        sign_out(user)
      end

      it 'キーワードで場所を検索できること' do
        VCR.use_cassette('google_api_search') do
          get facilities_index_path, params: { word: '池袋' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('池袋')
        end
      end

      it '都道府県と市区町村で検索できること' do
        VCR.use_cassette('google_api_search') do
          params = { prefecture_id: prefecture.id, city_id: city.id }
          get facilities_index_path, params: params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(prefecture.name)
          expect(response.body).to include(city.name)
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

  describe '#show' do
    let!(:facility) { create(:facility) }

    context '施設の情報について' do
      before do
        get facility_path(facility.id)
      end

      it '施設情報を取得できること' do
        expect(response.body).to include(facility.name)
        expect(response.body).to include(facility.address)
        expect(response).to have_http_status(:success)
      end

      it '施設の料金情報を取得できること' do
        expect(response.body).to include(facility.max_price.to_s)
        expect(response.body).to include(facility.min_price.to_s)
      end

      it '営業日と営業時間が取得できること' do
        facility.opening_hours.each do |opening_hour|
          expect(response.body).to include(I18n.t('date.abbr_day_names')[opening_hour.day_of_week])
          expect(response.body).to include(opening_hour.opening_time.strftime('%H:%M')) if opening_hour.opening_time.present?
          expect(response.body).to include(opening_hour.closing_time.strftime('%H:%M')) if opening_hour.closing_time.present?
        end
      end

      it '施設のサウナ設備の情報を取得できること' do
        expect(response.body).to include(facility.auto_louver ? '○' : '')
        expect(response.body).to include(facility.self_louver ? '○' : '')
        expect(response.body).to include(facility.aufguss ? '○' : '')
        expect(response.body).to include(facility.outdoor_bath ? '○' : '')
        expect(response.body).to include(facility.rest_area ? '○' : '')
      end

      it 'タオル・館内着・サウナマットの情報を取得できること' do
        expect(response.body).to include(facility.bath_towel)
        expect(response.body).to include(facility.face_towel)
        expect(response.body).to include(facility.in_house_wear)
        expect(response.body).to include(facility.sauna_mat)
      end

      it '館内設備の情報を取得できること' do
        expect(response.body).to include(facility.work_space ? '○' : '')
        expect(response.body).to include(facility.wifi ? '○' : '')
        expect(response.body).to include(facility.comics ? '○' : '')
        expect(response.body).to include(facility.in_house_rest_area ? '○' : '')
        expect(response.body).to include(facility.restaurant ? '○' : '')
      end

      it 'その他情報の取得ができること' do
        expect(response.body).to include(facility.free_text)
      end
    end
  end

  describe '#edit' do
    let(:user) { create(:user) }
    let(:facility) { create(:facility) }
    let(:in_sauna_facility) { create(:facility, aufguss: false, auto_louver: true, self_louver: true, outdoor_bath: false, rest_area: true) }
    let(:in_house_facility) { create(:facility, work_space: true, wifi: true, comics: false, in_house_rest_area: true, restaurant: false) }
    let(:facility_supply) { create(:facility, sauna_mat: '無料', bath_towel: '無料', face_towel: '無料', in_house_wear: '有料') }

    context '施設の情報について' do
      before do
        sign_in user
        get edit_facility_path(facility.id)
      end

      it '施設の名前と住所を取得できること' do
        expect(response.body).to include(facility.name)
        expect(response.body).to include(facility.address)
        expect(response).to have_http_status(:success)
      end

      it '施設の料金情報を取得できること' do
        expect(response.body).to include(facility.max_price.to_s)
        expect(response.body).to include(facility.min_price.to_s)
      end

      it '営業日と営業時間が取得できること' do
        facility.opening_hours.each do |opening_hour|
          expect(response.body).to include(I18n.t('date.abbr_day_names')[opening_hour.day_of_week])
          expect(response.body).to include(I18n.t('date.abbr_day_names')[opening_hour.day_of_week])
          expect(response.body).to include(opening_hour.opening_time.strftime('%H:%M')) if opening_hour.opening_time.present?
          expect(response.body).to include(opening_hour.closing_time.strftime('%H:%M')) if opening_hour.closing_time.present?
        end
      end

      it '施設のサウナ設備の情報を取得できること' do
        expect(in_sauna_facility.aufguss).to be_falsy
        expect(in_sauna_facility.auto_louver).to be_truthy
        expect(in_sauna_facility.self_louver).to be_truthy
        expect(in_sauna_facility.outdoor_bath).to be_falsy
        expect(in_sauna_facility.rest_area).to be_truthy
      end

      it 'タオル・館内着・サウナマットの情報を取得できること' do
        expect(facility_supply.sauna_mat).to eq('無料')
        expect(facility_supply.bath_towel).to eq('無料')
        expect(facility_supply.face_towel).to eq('無料')
        expect(facility_supply.in_house_wear).to eq('有料')
      end

      it '館内設備の情報を取得できること' do
        expect(in_house_facility.work_space).to be_truthy
        expect(in_house_facility.wifi).to be_truthy
        expect(in_house_facility.comics).to be_falsy
        expect(in_house_facility.in_house_rest_area).to be_truthy
        expect(in_house_facility.restaurant).to be_falsy
      end

      it 'その他情報の取得ができること' do
        expect(response.body).to include(facility.free_text)
      end
    end
  end

  describe '#update' do
    let(:user) { create(:user) }
    let(:facility) { create(:facility) }

    before do
      sign_in user
      get edit_facility_path(facility)
    end

    context '施設情報の更新について' do
      context '料金について' do
        it 'max_priceが変更された場合、更新できること' do
          new_max_price = facility.max_price + 1

          put facility_path(facility), params: {
            facility: {
              max_price: new_max_price
            }
          }

          facility.reload
          expect(facility.max_price).to eq(new_max_price)
          expect(response).to redirect_to(facility_path(facility))
        end

        it 'min_priceが変更された場合、更新できること' do
          new_min_price = facility.min_price + 1

          put facility_path(facility), params: {
            facility: {
              min_price: new_min_price
            }
          }

          facility.reload
          expect(facility.min_price).to eq(new_min_price)
          expect(response).to redirect_to(facility_path(facility))
        end

        it '料金に変更がない場合' do
          unchange_max_price = facility.max_price
          unchange_min_price = facility.min_price

          put facility_path(facility), params: {
            facility: {
              min_price: unchange_max_price.to_s,
              max_price: unchange_min_price.to_s
            }
          }

          facility.reload
          expect(facility.min_price).to eq(unchange_min_price)
          expect(facility.max_price).to eq(unchange_max_price)
          expect(response).to have_http_status(:ok)
        end
      end

      context 'サウナの設備について' do
        it '真偽地が変更された場合、値が更新できること' do
          put facility_path(facility), params: {
            facility: {
              aufguss: true,
              auto_louver: true,
              self_louver: true,
              rest_area: true,
              outdoor_bath: true
            }
          }

          facility.reload

          expect(response).to redirect_to(facility_path(facility))
          expect(facility.aufguss).to be true
          expect(facility.auto_louver).to be true
          expect(facility.self_louver).to be true
          expect(facility.rest_area).to be true
          expect(facility.outdoor_bath).to be true
        end

        it '真偽地が変更されていない場合、値が更新されないこと' do
          unchange_aufguss = facility.aufguss
          unchange_auto_louver = facility.auto_louver
          unchange_self_louver = facility.self_louver
          unchange_rest_area = facility.rest_area
          unchange_outdoor_bath = facility.outdoor_bath

          put facility_path(facility), params: {
            facility: {
              aufguss: unchange_aufguss,
              auto_louver: unchange_auto_louver,
              self_louver: unchange_self_louver,
              rest_area: unchange_rest_area,
              outdoor_bath: unchange_outdoor_bath
            }
          }

          facility.reload

          expect(response).to redirect_to(facility_path(facility))
          expect(facility.aufguss).to eq(unchange_aufguss)
          expect(facility.auto_louver).to eq(unchange_auto_louver)
          expect(facility.self_louver).to eq(unchange_self_louver)
          expect(facility.rest_area).to eq(unchange_rest_area)
          expect(facility.outdoor_bath).to eq(unchange_outdoor_bath)
        end
      end

      context 'タオル・館内着・サウナマットについて' do
        it '選択された値が取得できること' do
          put facility_path(facility), params: {
            facility: {
              sauna_mat: 'なし',
              in_house_wear: '無料（使い放題）',
              bath_towel: '無料（1枚）',
              face_towel: '有料（レンタル）'
            }
          }

          facility.reload

          expect(facility.sauna_mat).to eq('なし')
          expect(facility.in_house_wear).to eq('無料（使い放題）')
          expect(facility.bath_towel).to eq('無料（1枚）')
          expect(facility.face_towel).to eq('有料（レンタル）')
          expect(response).to redirect_to(facility_path(facility))
        end
      end

      context '館内設備について' do
        it '真偽地が変更された場合、値が更新できること' do
          put facility_path(facility), params: {
            facility: {
              work_space: true,
              wifi: true,
              comics: true,
              in_house_rest_area: true,
              restaurant: true
            }
          }

          facility.reload

          expect(response).to redirect_to(facility_path(facility))
          expect(facility.work_space).to be true
          expect(facility.wifi).to be true
          expect(facility.comics).to be true
          expect(facility.in_house_rest_area).to be true
          expect(facility.restaurant).to be true
        end

        it '真偽地が変更されていない場合、値が更新されないこと' do
          unchange_work_space = facility.work_space
          unchange_wifi = facility.wifi
          unchange_comics = facility.comics
          unchange_in_house_rest_area = facility.in_house_rest_area
          unchange_restaurant = facility.restaurant

          put facility_path(facility), params: {
            facility: {
              work_space: unchange_work_space,
              wifi: unchange_wifi,
              comics: unchange_comics,
              in_house_rest_area: unchange_in_house_rest_area,
              restaurant: unchange_restaurant
            }
          }

          facility.reload

          expect(response).to redirect_to(facility_path(facility))
          expect(facility.work_space).to eq(unchange_work_space)
          expect(facility.wifi).to eq(unchange_wifi)
          expect(facility.comics).to eq(unchange_comics)
          expect(facility.in_house_rest_area).to eq(unchange_in_house_rest_area)
          expect(facility.restaurant).to eq(unchange_restaurant)
        end
      end

      context 'その他の情報について' do
        it 'その他の情報を変更した場合、値が更新できること' do
          new_free_text = 'テキストの更新'
          put facility_path(facility), params: {
            facility: {
              free_text: new_free_text
            }
          }

          facility.reload

          expect(response).to redirect_to(facility_path(facility))
          expect(facility.free_text).to eq('テキストの更新')
        end

        it 'その他の情報が変更されていない場合、値が更新されないこと' do
          unchange_free_text = facility.free_text

          put facility_path(facility), params: {
            facility: {
              free_text: unchange_free_text
            }
          }

          facility.reload

          expect(response).to redirect_to(facility_path(facility))
          expect(facility.free_text).to eq(unchange_free_text)
        end
      end
    end
  end
end
