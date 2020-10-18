RSpec.describe ItemChangelog, type: :entity do
  describe 'Attributes' do
    it { is_expected.to respond_to :id }
    it { is_expected.to respond_to :item_id }
    it { is_expected.to respond_to :event_type }
    it { is_expected.to respond_to :changes }
    it { is_expected.to respond_to :created_at }
    it { is_expected.to respond_to :updated_at }
  end
end
