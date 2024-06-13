require 'rails_helper'

RSpec.describe 'Users', type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:guest_user) { create(:user, name: 'ゲスト') }
  let(:facility) { create(:facility) }
  let!(:favorite) { create(:favorite, user: user, facility: facility) }
  let!(:user_review) { create(:post, user: user) }

  describe '詳細ページのテスト' do
    context 'ログインしており、プロフィールの所有者である場合' do
      before do
        sign_in user
        visit user_path(user)
      end

      it 'ユーザープロフィールが表示されること' do
        expect(page).to have_css('.user-icon')
        expect(page).to have_content(user.name)
        expect(page).to have_content(user.my_rule)
      end

      it 'アカウント編集リンクが表示され、アカウント編集ページに遷移すること' do
        within '.account-content' do
          expect(page).to have_link('アカウントを編集する', href: edit_user_registration_path)

          find('.edit-ac').click
          expect(page).to have_current_path edit_user_registration_path, ignore_query: true
        end
      end

      it 'プロフィール編集リンクが表示され、プロフィール編集ページに遷移すること' do
        within '.btn-contents' do
          expect(page).to have_link('編集する', href: edit_user_path(user))

          find('.edit-prof').click
          expect(page).to have_current_path edit_user_path(user), ignore_query: true
        end
      end

      context 'ログインユーザーがゲストユーザーだった場合' do
        before do
          sign_out user
          sign_in guest_user
          visit user_path(guest_user)
        end

        it 'ユーザー名がゲストと表示されること' do
          expect(page).to have_content('ゲスト')
        end

        it 'アカウント編集リンクが表示されないこと' do
          expect(page).to have_no_link('アカウントを編集する', href: edit_user_registration_path)
        end

        it '編集ボタンが表示されないこと' do
          expect(page).to have_no_link('編集する', href: edit_user_path(user))
        end
      end

      it 'お気に入り登録した施設が表示されること' do
        expect(page).to have_content('お気に入り')
        expect(page).to have_content(facility.name)
        expect(page).to have_content(facility.address)
      end

      it '削除ボタンが表示され、ボタンを押すと削除されていること' do
        within '.favorite-content' do
          expect(page).to have_button('削除する')

          click_link_or_button '削除する'

          expect(page).to have_current_path user_path(user), ignore_query: true

          visit current_path
          expect(page).to have_no_content(favorite.facility.name)
        end
      end

      it '自身の投稿が表示され、削除ボタンを押下すると削除されること' do
        expect(page).to have_content(user_review.name)
        expect(page).to have_content(user_review.title)
        expect(page).to have_content(user_review.review)
        expect(page).to have_css('.post-time')

        within '.post-item' do
          click_on '削除'
        end

        expect(page).to have_no_content(user_review.name)
        expect(page).to have_no_content(user_review.title)
        expect(page).to have_no_content(user_review.review)
        expect(page).to have_no_css('.post-time')
      end
    end

    context 'ユーザーがログインしていない場合' do
      before do
        visit user_path(user)
      end

      it 'ユーザープロフィールが表示されること' do
        expect(page).to have_css('.user-icon')
        expect(page).to have_content(user.name)
        expect(page).to have_content(user.my_rule)
      end

      it 'アカウント編集リンクが表示されないこと' do
        expect(page).to have_no_link('アカウントを編集する', href: edit_user_registration_path)
      end

      it '編集ボタンが表示されないこと' do
        expect(page).to have_no_link('編集する', href: edit_user_path(user))
      end

      it 'お気に入り登録した施設が表示されること' do
        expect(page).to have_content('お気に入り')
        expect(page).to have_content(facility.name)
        expect(page).to have_content(facility.address)
      end

      it '削除ボタンが表示されないこと' do
        within '.favorite-content' do
          expect(page).to have_no_button('削除する')
        end
      end
    end

    context 'ユーザーがログインしており、プロフィールの所有者ではない場合' do
      before do
        sign_in other_user
        visit user_path(user)
      end

      it 'ユーザープロフィールが表示されること' do
        expect(page).to have_css('.user-icon')
        expect(page).to have_content(user.name)
        expect(page).to have_content(user.my_rule)
      end

      it 'アカウント編集リンクが表示されないこと' do
        expect(page).to have_no_link('アカウントを編集する', href: edit_user_registration_path)
      end

      it '編集ボタンが表示されないこと' do
        expect(page).to have_no_link('編集する', href: edit_user_path(user))
      end

      it 'お気に入り登録した施設が表示されること' do
        expect(page).to have_content('お気に入り')
        expect(page).to have_content(facility.name)
        expect(page).to have_content(facility.address)
      end

      it '削除ボタンが表示されないこと' do
        within '.favorite-content' do
          expect(page).to have_no_button('削除する')
        end
      end
    end
  end

  describe '編集ページのテスト' do
    before do
      sign_in user
      visit edit_user_path(user)
    end

    it '現在のプロフィールが表示されること' do
      expect(page).to have_content('プロフィール編集')
      expect(page).to have_field('user_icon_image', type: 'file')
      expect(page).to have_field('ユーザー名', with: user.name)
      expect(page).to have_field('Myルール', with: user.my_rule)
    end

    it 'プロフィールが更新されること' do
      fill_in 'ユーザー名', with: 'New Name'
      fill_in 'Myルール', with: 'New rule'
      attach_file('user_icon_image', Rails.root.join('spec/fixtures/files/image_test.jpg'))

      find('.save').click

      expect(page).to have_current_path user_path(user), ignore_query: true

      expect(page).to have_content('New Name')
      expect(page).to have_content('New rule')
      expect(user.reload.icon_image).to be_attached
    end
  end
end
