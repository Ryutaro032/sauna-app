require 'rails_helper'

RSpec.describe 'Facilities', :js, type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'ホーム画面のテストについて' do
    let(:user) { create(:user) }

    context 'ユーザーがログインしている場合' do
      before do
        sign_in(user)
      end

      context 'トップページ画面について' do
        it 'トップページが表示されること' do
          visit root_path
          expect(page).to have_http_status(:ok)
        end

        it 'キーワード検索ができ、リストページに結果とお気に入りボタンが表示されること' do
          visit root_path

          fill_in 'キーワードを入力', with: '池袋'
          click_link_or_button '検索'

          visit facility_index_path(word: '池袋')
          expect(page).to have_http_status(:ok)
          expect(page).to have_content('池袋')

          expect(page).to have_css('tr:first-child .add-favorite', visible: :all)
          expect(page).to have_no_css('tr:first-child .remove-favorite')

          find('tr:first-child .add-favorite').click

          expect(page).to have_css('tr:first-child .remove-favorite', visible: :all)
          expect(page).to have_no_css('tr:first-child .add-favorite')

          find('tr:first-child .remove-favorite').click

          expect(page).to have_css('tr:first-child .add-favorite', visible: :all)
          expect(page).to have_no_css('tr:first-child .remove-favorite')
        end
      end
    end

    context 'ユーザーがログインしていない場合' do
      before do
        sign_out(user)
      end

      it 'トップページが表示されること' do
        visit root_path
        expect(page).to have_http_status(:ok)
      end

      it 'キーワード検索ができ、リストページに結果が表示され、お気に入りボタンが表示されないこと' do
        visit root_path

        fill_in 'キーワードを入力', with: '池袋'
        click_link_or_button '検索'

        expect(page).to have_http_status(:ok)
        expect(page).to have_content('池袋')

        expect(page).to have_no_css('tr .favorite-btn')
      end
    end
  end

  describe '検索リスト表示画面のテストについて' do
    let(:user) { create(:user) }

    context '検索結果の表示について' do
      it 'リストページが表示されること' do
        visit facility_index_path
        expect(page).to have_http_status(:ok)
      end

      it 'キーワード検索を行い、表示されること' do
        visit facility_index_path(word: '池袋')
        expect(page).to have_http_status(:ok)
        expect(page).to have_content('池袋')
      end
    end

    context 'ユーザーがログインしている場合' do
      before do
        sign_in(user)
      end

      describe 'お気に入り追加について' do
        before do
          visit facility_index_path(word: '池袋')
        end

        it 'お気に入り追加/削除が表示され、切り替えが正しく動作すること' do
          expect(page).to have_css('tr:first-child .add-favorite', visible: :all)
          expect(page).to have_no_css('tr:first-child .remove-favorite')

          find('tr:first-child .add-favorite').click

          expect(page).to have_css('tr:first-child .remove-favorite', visible: :all)
          expect(page).to have_no_css('tr:first-child .add-favorite')

          find('tr:first-child .remove-favorite').click

          expect(page).to have_css('tr:first-child .add-favorite', visible: :all)
          expect(page).to have_no_css('tr:first-child .remove-favorite')
        end
      end
    end

    context 'ユーザーがログインしていない場合' do
      before do
        sign_out(user)
      end

      it 'お気に入り追加/削除ボタンが表示されないこと' do
        expect(page).to have_no_css('tr, favorite-btn')
      end
    end
  end
end
