require 'rails_helper'

RSpec.describe ReviewLike, type: :model do
  let(:user) { create(:user) }
  let(:post) { create(:post) }

  describe 'アソシエーションについて' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:post) }
  end
end
