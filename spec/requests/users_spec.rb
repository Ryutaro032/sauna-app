require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:facility) { create(:facility) }
  let!(:favorite) { create(:favorite, user: user, facility: facility) }
  let!(:user_post) { create(:post, user: user) }
  let!(:other_post) { create(:post, user: other_user) }

  describe '#show' do
    context '閲覧者がプロフィールの所有者の場合' do
      before do
        sign_in user
        get user_path(user)
      end

      it 'ユーザーの詳細ページにアクセスできること' do
        expect(response).to have_http_status(:ok)
      end

      it 'ユーザー名が表示されること' do
        expect(response.body).to include user.name
      end

      it 'Myルールが表示されること' do
        expect(response.body).to include user.my_rule
      end

      it '画像が表示されること' do
        expect(response.body).to include('user-icon"')
      end

      it 'お気に入りの施設が表示されること' do
        expect(assigns(:favorites)).to include favorite
      end

      it 'お気に入り登録した施設名が表示されること' do
        expect(response.body).to include favorite.facility.name
      end

      it 'お気に入り登録した施設の住所が表示されること' do
        expect(response.body).to include favorite.facility.address
      end

      it '削除ボタンが表示されること' do
        expect(response.body).to include('削除する')
      end

      it '自身の投稿のみが表示されること' do
        expect(assigns(:user_reviews)).to include(user_post)
        expect(assigns(:user_reviews)).not_to include(other_post)
      end

      it '投稿内容が表示されること' do
        expect(response.body).to include user_post.name
        expect(response.body).to include user_post.title
        expect(response.body).to include user_post.review
      end
    end

    context '閲覧者がプロフィールの所有者でない場合' do
      before do
        sign_in other_user
        get user_path(user)
      end

      it 'ユーザーの詳細ページにアクセスできること' do
        expect(response).to have_http_status(:ok)
      end

      it 'ユーザー名が表示されること' do
        expect(response.body).to include user.name
      end

      it 'Myルールが表示されること' do
        expect(response.body).to include user.my_rule
      end

      it '画像が表示されること' do
        expect(response.body).to include('user-icon"')
      end

      it 'お気に入りの施設が表示されること' do
        expect(assigns(:favorites)).to include favorite
      end

      it 'お気に入り登録した施設名が表示されること' do
        expect(response.body).to include favorite.facility.name
      end

      it 'お気に入り登録した施設の住所が表示されること' do
        expect(response.body).to include favorite.facility.address
      end

      it '削除ボタンが表示されないこと' do
        expect(response.body).not_to include('削除する')
      end
    end
  end

  describe '#edit' do
    before do
      sign_in user
    end

    context 'ユーザーが認証されている場合' do
      before do
        get edit_user_path(user)
      end

      it '編集ページにアクセスできる' do
        expect(response).to have_http_status(:ok)
      end

      it 'ユーザー名が表示されること' do
        expect(response.body).to include user.name
      end

      it 'Myルールが表示されること' do
        expect(response.body).to include user.my_rule
      end
    end
  end

  describe '#update' do
    let(:updated_user) { { user: { name: 'New Name', my_rule: 'a' * 100 } } }

    context 'ユーザーが認証されている場合' do
      before do
        sign_in user
      end

      context 'パラメータが有効な場合' do
        before do
          patch user_path(user), params: updated_user
          follow_redirect!
        end

        it 'ユーザー情報を更新し、ユーザー表示ページにリダイレクトできる' do
          expect(response).to render_template(:show)
        end

        it 'ユーザー名が変更されること' do
          expect(response.body).to include('New Name')
        end

        it 'myルールが変更されること' do
          expect(response.body).to include('a' * 100)
        end
      end

      context 'パラメータが無効な場合' do
        it '更新せず、編集ページにリダイレクトになる' do
          patch user_path(user), params: { user: { name: '' } }
          expect(response).to render_template(:edit)
        end
      end
    end
  end
end
