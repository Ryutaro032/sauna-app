require 'rails_helper'

RSpec.describe 'Facilities', :js, type: :system do
  describe 'ホーム画面のテストについて' do
    let(:user) { create(:user) }
    let!(:prefecture) { create(:prefecture) }
    let!(:post) { create(:post, created_at: 2.hours.ago) }

    context 'ユーザーがログインしている場合' do
      before do
        sign_in(user)
      end

      context 'トップページ画面について' do
        it 'トップページが表示されること' do
          visit root_path
          expect(page).to have_content('サウナログ')
        end

        it 'キーワード検索ができ、リストページに結果とお気に入りボタンが表示されること' do
          visit root_path

          fill_in 'キーワードを入力', with: '池袋'
          click_link_or_button '検索'

          visit facilities_index_path(word: '池袋')
          expect(page).to have_content('池袋')

          expect(page).to have_css('tr:first-child .add-favorite', visible: :all)
          expect(page).to have_no_css('tr:first-child .remove-favorite')

          find('tr:first-child .add-favorite').click

          expect(page).to have_css('tr:first-child .remove-favorite', visible: :all)
          expect(page).to have_no_css('tr:first-child .add-favorite')
        end

        it '都道府県の検索ができること' do
          visit root_path

          expect(page).to have_css("#prefecture_select option[value='#{prefecture.id}']")
          find_by_id('prefecture_select').find("option[value='#{prefecture.id}']").select_option

          click_link_or_button '検索'

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

      it 'キーワード検索ができ、リストページに結果が表示され、お気に入りボタンが表示されないこと' do
        visit root_path

        fill_in 'キーワードを入力', with: '池袋'
        click_link_or_button '検索'

        expect(page).to have_content('池袋')
        expect(page).to have_no_css('tr .favorite-btn')
      end
    end

    context '施設のレビューの表示について' do
      it 'レビューが表示されること、いいねボタンが表示されること' do
        visit root_path

        within first('.post-item') do
          expect(page).to have_css('.user-icon')
          expect(page).to have_content(post.name)
          expect(page).to have_link(post.name, href: facilities_index_path(place_name: post.name))
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

    context '検索結果の表示について' do
      it 'リストページが表示されること' do
        visit facilities_index_path
        expect(page).to have_content('サウナログ')
      end

      it 'キーワード検索を行い、表示されること' do
        visit facilities_index_path(word: '池袋')
        expect(page).to have_content('サウナログ')
        expect(page).to have_content('池袋')
      end

      it '都道府県の検索ができること' do
        visit facilities_index_path

        expect(page).to have_css("#prefecture_select option[value='#{prefecture.id}']")
        find_by_id('prefecture_select').find("option[value='#{prefecture.id}']").select_option

        click_link_or_button '検索'

        expect(page).to have_content('サウナログ')
      end
    end

    context 'ユーザーがログインしている場合' do
      before do
        sign_in(user)
      end

      describe 'お気に入り追加について' do
        before do
          visit facilities_index_path(word: '池袋')
        end

        it 'お気に入り追加/削除が表示され、切り替えが正しく動作すること' do
          expect(page).to have_css('tr:first-child .add-favorite', visible: :all)
          expect(page).to have_no_css('tr:first-child .remove-favorite')

          find('tr:first-child .add-favorite').click

          expect(page).to have_css('tr:first-child .remove-favorite', visible: :all)
          expect(page).to have_no_css('tr:first-child .add-favorite')
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
