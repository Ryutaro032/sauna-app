require 'rails_helper'

RSpec.describe OpeningHour, type: :model do
  let(:facility) { create(:facility) }

  describe 'バリデーションについて' do
    it 'day_of_weekがない場合、エラーが発生すること' do
      opening_hour = build(:opening_hour, day_of_week: nil)
      expect(opening_hour).not_to be_valid
      expect(opening_hour.errors[:day_of_week]).to include('を入力してください')
    end

    it 'closing_timeがopening_timeよりも後の時間の場合、エラーが発生しないこと' do
      opening_hour = build(:opening_hour, day_of_week: 1, opening_time: '10:00', closing_time: '11:00')
      expect(opening_hour).to be_valid
    end

    it 'closing_timeのみnullの場合、エラーが発生しないこと' do
      opening_hour = build(:opening_hour, day_of_week: 1, opening_time: '10:00', closing_time: nil)
      expect(opening_hour).to be_valid
    end

    it 'opening_timeのみnullの場合、エラーが発生しないこと' do
      opening_hour = build(:opening_hour, day_of_week: 1, opening_time: nil, closing_time: '11:00')
      expect(opening_hour).to be_valid
    end
  end

  describe 'アソシエーションについて' do
    it 'belongs to facility' do
      association = described_class.reflect_on_association(:facility)
      expect(association.macro).to eq :belongs_to
    end
  end
end
