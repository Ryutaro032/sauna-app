require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let(:guest_user) { described_class.guest }

  describe "アソシエーションについて" do
    it { should have_many(:favorites).dependent(:destroy) }
    it { should have_many(:facilities).through(:favorites) }
  end

  describe 'バリデーションについて' do
    it 'ユーザー名が空白の場合にエラーメッセージが返ってくるか' do
      user.name = ''
      user.valid?
      expect(user.errors[:name]).to include('を入力してください')
    end

    it 'ユーザー名の文字数が21文字以上の場合エラーメッセージが返ってくるか' do
      user.name = 'a' * 21
      user.valid?
      expect(user.errors[:name]).to include('は20文字以内で入力してください')
    end

    it 'emailが空白の場合にエラーメッセージが返ってくるか' do
      user.email = ''
      user.valid?
      expect(user.errors[:email]).to include('を入力してください')
    end

    it 'passwordが空白の場合にエラーメッセージが返ってくるか' do
      user.password = ''
      user.valid?
      expect(user.errors[:password]).to include('を入力してください')
    end

    it 'password（確認用）が空白の場合にエラーメッセージが返ってくるか' do
      user.password_confirmation = ''
      user.valid?
      expect(user.errors[:password_confirmation]).to include('を入力してください')
    end

    it 'passwordの文字数が5文字以下の場合エラーメッセージが返ってくるか' do
      user.password = 'a' * 5
      user.valid?
      expect(user.errors[:password]).to include('は6文字以上で入力してください')
    end

    it 'プロフィールのMyルールの文字数が401文字以上の場合エラーメッセージが返ってくるか' do
      user.my_rule = 'a' * 401
      user.valid?
      expect(user.errors[:my_rule]).to include('は400文字以内で入力してください')
    end

    context '一意性制約の確認' do
      it '同じemailの場合エラーメッセージが返ってくるか' do
        user.save
        another_user = build(:user)
        another_user.email = user.email
        another_user.valid?
        expect(another_user.errors[:email]).to include('はすでに存在します')
      end
    end
  end

  describe 'ゲスト用ログイン' do
    it 'ゲスト用でログインできること' do
      expect(guest_user.email).to eq('guest@example.com')
      expect(guest_user.name).to eq('ゲスト')
      expect(guest_user.id).to eq(1)
    end
  end
end
