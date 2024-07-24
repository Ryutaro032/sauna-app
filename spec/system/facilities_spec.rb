require 'rails_helper'

RSpec.describe 'Facilities', :js, type: :system do
  describe 'ホーム画面のテストについて' do
    let(:user) { create(:user) }
    let(:facility) { create(:facility) }
    let!(:prefecture) { create(:prefecture) }
    let!(:post) { create(:post, facility: facility, user: user, created_at: 2.hours.ago) }

    context 'ユーザーがログインしている場合' do
      before do
        sign_in(user)
      end

      context 'トップページ画面について' do
        it 'トップページが表示されること' do
          visit root_path
          expect(page).to have_content('サウナログ')
        end

        it 'キーワード検索ができ、リストページに結果が表示されること' do
          visit root_path

          fill_in 'キーワードを入力', with: '池袋'

          within('.search-form') do
            click_link_or_button '検索'
          end

          visit facilities_index_path(word: '池袋')
          expect(page).to have_content('池袋')
        end

        it '都道府県の検索ができること' do
          visit root_path

          expect(page).to have_css("#prefecture_select option[value='#{prefecture.id}']")
          find_by_id('prefecture_select').find("option[value='#{prefecture.id}']").select_option

          within('.search-form') do
            click_link_or_button '検索'
          end

          expect(page).to have_content('サウナログ')
        end

        it 'いいねボタンが表示され、ボタンの切り替えができること' do
          visit root_path

          within(first('.post-item')) do
            if page.has_css?('.unlike-button')
              expect(page).to have_css('.unlike-button', visible: :all)
              expect(page).to have_no_css('.like-button')

              expect do
                page.execute_script("document.querySelector('.like-button').style.position = 'relative'; document.querySelector('.like-button').style.left = '100px'")
                find('.unlike-button').click
                expect(page).to have_no_css('.unlike-button')
              end.to change { ReviewLike.where(post_id: post.id, user_id: user.id).count }.by(-1)
            elsif page.has_css?('.like-button')
              expect(page).to have_css('.like-button', visible: :all)
              expect(page).to have_no_css('.unlike-button')

              expect do
                page.execute_script("document.querySelector('.like-button').style.position = 'relative'; document.querySelector('.like-button').style.left = '100px'")
                find('.like-button').click
                expect(page).to have_no_css('.like-button')
              end.to change { ReviewLike.where(post_id: post.id, user_id: user.id).count }.by(1)
            end
          end
        end
      end
    end

    context 'ユーザーがログインしていない場合' do
      before do
        sign_out(user)
      end

      it 'トップページが表示されること' do
        visit root_path
        expect(page).to have_content('サウナログ')
      end

      it 'キーワード検索ができ、リストページに結果が表示されること' do
        visit root_path

        fill_in 'キーワードを入力', with: '池袋'

        within('.search-form') do
          click_link_or_button '検索'
        end

        expect(page).to have_content('池袋')
      end
    end

    context '施設のレビューの表示について' do
      it 'レビューが表示されること、いいねボタンが表示されること' do
        visit root_path

        within first('.post-item') do
          expect(page).to have_css('.user-icon')
          expect(page).to have_content(post.name)
          expect(page).to have_link(post.name, href: facility_path(facility.id))
          expect(page).to have_content(post.title)
          expect(page).to have_content(post.review)
          expect(page).to have_content('約2時間前')
        end
      end
    end
  end

  describe '検索リスト表示画面のテストについて' do
    let(:user) { create(:user) }
    let!(:prefecture) { create(:prefecture) }
    let(:facility) { create(:facility) }

    context 'ユーザーがログインしている場合' do
      before do
        sign_in(user)
      end

      context '検索結果の表示について' do
        it 'リストページが表示されること' do
          visit facilities_index_path
          expect(page).to have_content('サウナログ')
        end

        it 'キーワード検索を行い、結果が表示できること' do
          visit facilities_index_path

          fill_in 'キーワードを入力', with: '池袋'

          within('.search-form') do
            click_link_or_button '検索'
          end

          visit facilities_index_path(word: '池袋')
          expect(page).to have_content('サウナログ')
          expect(page).to have_css('.facility-name .list-item')
          expect(page).to have_content('施設情報')
          expect(page).to have_css('.review-btn')
        end

        it '都道府県の検索ができること' do
          visit facilities_index_path

          expect(page).to have_css("#prefecture_select option[value='#{prefecture.id}']")
          find_by_id('prefecture_select').find("option[value='#{prefecture.id}']").select_option

          within('.search-form') do
            click_link_or_button '検索'
          end

          expect(page).to have_content('サウナログ')
          expect(page).to have_css('.facility-name .list-item')
          expect(page).to have_content('施設情報')
          expect(page).to have_css('.review-btn')
        end
      end

      it '投稿ページに遷移できること' do
        visit facilities_index_path

        fill_in 'キーワードを入力', with: '池袋'

        within('.search-form') do
          click_link_or_button '検索'
        end

        visit facilities_index_path(word: '池袋')

        find('.link.link-btn.review-btn', match: :first).click

        expect(page).to have_current_path(new_post_path, ignore_query: true)
      end
    end

    context 'ユーザーがログインしていない場合' do
      before do
        sign_out(user)
      end

      it '投稿ボタンが表示されないこと' do
        visit facilities_index_path

        fill_in 'キーワードを入力', with: '池袋'

        within('.search-form') do
          click_link_or_button '検索'
        end

        visit facilities_index_path(word: '池袋')
        expect(page).to have_content('サウナログ')
        expect(page).to have_css('.facility-name .list-item')
        expect(page).to have_content('施設情報')
        expect(page).to have_no_css('.review-btn')
      end
    end
  end

  describe '条件検索のテストについて' do
    let(:facility_boolean) { create(:facility, outdoor_bath: true) }
    let(:facility_select) { create(:facility, sauna_mat: '無料（使い放題）') }

    context '条件検索が機能すること' do
      it 'チェックボックスが機能すること' do
        visit root_path

        find('.con-search .modal-search', text: '条件から探す').click

        within(first('.modal-search-contents')) do
          first('.con-search-content .search-checkbox').check('outdoor_bath')

          click_link_or_button '検索'
        end

        visit facilities_index_path(outdoor_bath: '1')
        expect(page).to have_css('.facility-name')
      end

      it 'セレクトボックスが機能すること' do
        visit root_path
        find('.con-search .modal-search', text: '条件から探す').click

        within(first('.modal-search-contents')) do
          first('.con-search-content .search-select').select '無料（使い放題）', from: 'sauna_mat'

          click_link_or_button '検索'
        end

        visit facilities_index_path(sauna_mat: '無料（使い放題）')
        expect(page).to have_css('.facility-name')
      end
    end
  end

  describe '施設の詳細ページについて' do
    let(:user) { create(:user) }
    let(:facility) { create(:facility) }
    let!(:facility_review) { create(:post, user: user, facility: facility) }

    it '施設の詳細ページへのアクセスに成功する' do
      visit facility_path(facility.id)
      expect(page).to have_content(facility.name)
      expect(page).to have_content(facility.address)
    end

    it '施設の投稿が表示されること' do
      visit facility_path(facility.id)
      expect(page).to have_content(facility_review.name)
      expect(page).to have_content(facility_review.title)
      expect(page).to have_content(facility_review.review)
    end

    context 'ユーザーがログインしている場合' do
      before do
        sign_in(user)
      end

      it 'お気に入りボタンが表示され、切り替えができること' do
        visit facility_path(facility.id)

        expect(page).to have_button('お気に入りに追加')
        expect(page).to have_no_button('お気に入りから削除')

        page.execute_script("document.querySelector('.header-container').remove();")

        click_link_or_button 'お気に入りに追加'
        expect(page).to have_button('お気に入りから削除')
        expect(page).to have_no_button('お気に入りに追加')
        expect(page).to have_content('お気に入りに登録しました')

        page.execute_script("document.querySelector('.header-container').remove();")

        click_link_or_button 'お気に入りから削除'
        expect(page).to have_button('お気に入りに追加')
        expect(page).to have_no_button('お気に入りから削除')
        expect(page).to have_content('お気に入りから削除しました')
      end

      it '行きたいリストへ登録するボタンが表示され、切り替えができること' do
        visit facility_path(facility.id)

        expect(page).to have_button('行きたいリストに追加')
        expect(page).to have_no_button('行きたいリストから削除')

        page.execute_script("document.querySelector('.header-container').remove();")

        click_link_or_button '行きたいリストに追加'
        expect(page).to have_button('行きたいリストから削除')
        expect(page).to have_no_button('行きたいリストに追加')
        expect(page).to have_content('行きたいリストに登録しました')

        page.execute_script("document.querySelector('.header-container').remove();")

        click_link_or_button '行きたいリストから削除'
        expect(page).to have_button('行きたいリストに追加')
        expect(page).to have_no_button('行きたいリストから削除')
        expect(page).to have_content('行きたいリストから削除しました')
      end
    end

    context 'ユーザーがログインしていない場合' do
      before do
        sign_out(user)
      end

      it 'お気に入りボタンが表示されないこと' do
        visit facility_path(facility.id)

        expect(page).to have_no_button('お気に入りに追加')
      end

      it '行きたいリストへの登録ボタンが表示されないこと' do
        visit facility_path(facility.id)

        expect(page).to have_no_button('行きたいリストに追加')
      end
    end
  end

  describe '施設の編集ページについて' do
    let(:user) { create(:user) }
    let!(:facility) { create(:facility) }

    before do
      sign_in(user)
      visit edit_facility_path(facility)
    end

    it '施設の編集ページへのアクセスに成功する' do
      expect(page).to have_content(facility.name)
      expect(page).to have_content(facility.address)
      expect(page).to have_content('基本情報')
      expect(page).to have_content('サウナ設備')
      expect(page).to have_content('タオル・館内着・サウナマット')
      expect(page).to have_content('館内設備')
      expect(page).to have_content('その他の情報')
    end

    it '曜日・時間が表示されること' do
      check 'facility_opening_hours_attributes_0_holiday'

      expect(page).to have_checked_field('facility_opening_hours_attributes_0_holiday')

      select '10', from: 'facility_opening_hours_attributes_6_opening_time_4i'
      select '00', from: 'facility_opening_hours_attributes_6_opening_time_5i'
      select '18', from: 'facility_opening_hours_attributes_6_closing_time_4i'
      select '00', from: 'facility_opening_hours_attributes_6_closing_time_5i'

      click_link_or_button '更新する'

      facility.reload

      expect(page).to have_current_path(facility_path(facility))

      expect(page).to have_content('定休日')
      expect(page).to have_content('10:00')
      expect(page).to have_content('18:00')
    end

    it '料金の値が更新され、表示できること' do
      expect(page).to have_content('料金')

      fill_in 'facility_min_price', with: 100
      fill_in 'facility_max_price', with: 500
      click_link_or_button '更新する'

      facility.reload

      expect(page).to have_current_path(facility_path(facility))
      expect(page).to have_content('施設情報が更新されました。')
      expect(page).to have_content('100〜500')
    end

    it 'サウナ設備の値が更新され、表示できること' do
      expect(page).to have_content('ロウリュ（アウフグース）')
      expect(page).to have_content('オートロウリュ')
      expect(page).to have_content('セルフロウリュ')
      expect(page).to have_content('休憩スペース（整いスペース）')
      expect(page).to have_content('外気浴')

      check 'facility_aufguss'
      check 'facility_auto_louver'
      check 'facility_self_louver'
      check 'facility_rest_area'
      check 'facility_outdoor_bath'

      expect(page).to have_checked_field('facility_aufguss')
      expect(page).to have_checked_field('facility_auto_louver')
      expect(page).to have_checked_field('facility_self_louver')
      expect(page).to have_checked_field('facility_rest_area')
      expect(page).to have_checked_field('facility_outdoor_bath')

      click_link_or_button '更新する'

      facility.reload

      expect(page).to have_current_path(facility_path(facility))
      expect(page).to have_content('施設情報が更新されました。')
      expect(page).to have_css('.facility-auguss', text: '○')
      expect(page).to have_css('.facility-auto-louver', text: '○')
      expect(page).to have_css('.facility-self-louver', text: '○')
      expect(page).to have_css('.facility-rest-area', text: '○')
      expect(page).to have_css('.facility-outdoor-bath', text: '○')
    end

    it 'タオル・館内着・サウナマット情報の値が更新され、表示できること' do
      expect(page).to have_content('サウナマット')
      expect(page).to have_select('facility_sauna_mat', options: ['', 'なし', '無料（使い放題）', '無料（1枚）', '有料（レンタル）'])

      expect(page).to have_content('館内着')
      expect(page).to have_select('facility_in_house_wear', options: ['', 'なし', '無料（使い放題）', '無料（1枚）', '有料（レンタル）'])

      expect(page).to have_content('バスタオル')
      expect(page).to have_select('facility_bath_towel', options: ['', 'なし', '無料（使い放題）', '無料（1枚）', '有料（レンタル）'])

      expect(page).to have_content('フェイスタオル')
      expect(page).to have_select('facility_face_towel', options: ['', 'なし', '無料（使い放題）', '無料（1枚）', '有料（レンタル）'])

      select '無料（使い放題）', from: 'facility_sauna_mat'
      select '有料（レンタル）', from: 'facility_in_house_wear'
      select 'なし', from: 'facility_bath_towel'
      select '無料（1枚）', from: 'facility_face_towel'

      click_link_or_button '更新する'

      facility.reload

      expect(page).to have_current_path(facility_path(facility))
      expect(page).to have_content('施設情報が更新されました。')
      expect(facility.reload.sauna_mat).to eq('無料（使い放題）')
      expect(facility.in_house_wear).to eq('有料（レンタル）')
      expect(facility.bath_towel).to eq('なし')
      expect(facility.face_towel).to eq('無料（1枚）')
    end

    it '館内設備の値が更新され、表示できること' do
      expect(page).to have_content('作業スペース')
      expect(page).to have_content('休憩スペース')
      expect(page).to have_content('Wi-Fi')
      expect(page).to have_content('漫画')
      expect(page).to have_content('食事処')

      check 'facility_work_space'
      check 'facility_in_house_rest_area'
      check 'facility_wifi'
      check 'facility_comics'
      check 'facility_restaurant'

      expect(page).to have_checked_field('facility_work_space')
      expect(page).to have_checked_field('facility_in_house_rest_area')
      expect(page).to have_checked_field('facility_wifi')
      expect(page).to have_checked_field('facility_comics')
      expect(page).to have_checked_field('facility_restaurant')

      click_link_or_button '更新する'

      facility.reload

      expect(page).to have_current_path(facility_path(facility))
      expect(page).to have_content('施設情報が更新されました。')
      expect(page).to have_css('.work-space', text: '○')
      expect(page).to have_css('.in-house-rest-area', text: '○')
      expect(page).to have_css('.wifi', text: '○')
      expect(page).to have_css('.comics', text: '○')
      expect(page).to have_css('.restaurant', text: '○')
    end

    it 'その他の情報が更新され、表示できること' do
      expect(page).to have_content(facility.free_text)

      fill_in 'facility_free_text', with: 'テキストを更新'
      click_link_or_button '更新する'

      facility.reload

      expect(page).to have_current_path(facility_path(facility))
      expect(page).to have_content('施設情報が更新されました。')
      expect(page).to have_content('テキストを更新')
    end
  end
end
