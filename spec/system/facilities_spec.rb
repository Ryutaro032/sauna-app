require 'rails_helper'

RSpec.describe 'Facilities', :js, type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'index' do
    let(:user) { create(:user) }

    context 'ユーザーがログインしている場合' do
      before do
        sign_in(user)
      end

      it 'リストページが表示されること' do
        visit facility_index_path
        expect(page).to have_http_status(:ok)
      end

      it 'キーワード検索を行い、表示されること' do
        visit facility_index_path(word: '池袋')
        expect(page).to have_http_status(:ok)
        expect(page).to have_content('池袋')
        expect(page).to have_css('tr', count: 5)
      end

      describe 'お気に入り追加について' do
        before do
          visit facility_index_path(word: '池袋')
        end

        it 'お気に入り追加/削除の切り替えが正しく動作すること' do
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

      it 'リストページが表示されること' do
        visit facility_index_path
        expect(page).to have_http_status(:ok)
      end

      it 'キーワード検索を行い、表示されること' do
        visit facility_index_path(word: '池袋')
        expect(page).to have_http_status(:ok)
        expect(page).to have_content('池袋')
        expect(page).to have_css('tr', count: 5)
      end

      it 'キーワードがない場合、トップページに戻ること' do
        visit facility_index_path
        expect(page).to have_http_status(:ok)
        expect(page).to have_css('.flash', text: 'キーワードを入力してください')
      end
    end
  end
end
