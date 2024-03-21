require 'rails_helper'

RSpec.describe "ApplicationController", type: :request do
  describe "before_action :configure_permitted_parametersについて" do
    let(:user_params) { attributes_for(:user) }

    context "サインアップするとき" do
      it "emailパラメータを許可すること" do
        post user_registration_path, params: { user: user_params }
        expect(User.last.email).to eq(user_params[:email])
      end

      it "emailパラメータを許可しないこと" do
        post user_registration_path, params: { user: { email: "test@example.com", password: "password", password_confirmation: "password" } }
        expect(User.last).to be_nil
      end
    end
  end
end
