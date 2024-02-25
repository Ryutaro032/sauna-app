require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }
  let(:updated_user) { { user: { name: 'New Name', my_rule: 'a' * 100 } } }

  describe '#show' do
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
    context 'ユーザーが認証されている場合' do
      before do
        sign_in user
      end

      context 'パラメータが有効な時' do
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

      context 'パラメータが無効な時' do
        it '更新せず、編集ページにリダイレクトになる' do
          patch user_path(user), params: { user: { name: '' } }
          expect(response).to render_template(:edit)
        end
      end
    end
  end
end
