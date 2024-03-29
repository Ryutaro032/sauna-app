require 'rails_helper'

RSpec.describe Favorite, type: :model do
  let(:user) { create(:user) }
  let(:facility) { create(:facility) }

  describe 'バリデーションについて' do
    it 'user_idをスコープとするfacility_idの一意性について' do
      user = create(:user)

      new_favorite = described_class.new(user: user, facility: facility)
      expect(new_favorite).to validate_uniqueness_of(:facility_id).scoped_to(:user_id)
    end
  end

  describe 'アソシエーションについて' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:facility).dependent(:destroy) }
  end
end
