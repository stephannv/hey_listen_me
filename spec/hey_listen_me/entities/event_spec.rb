RSpec.describe Event, type: :entity do
  describe 'Attributes' do
    it { is_expected.to respond_to :id }
    it { is_expected.to respond_to :raw_info_id }
    it { is_expected.to respond_to :type }
    it { is_expected.to respond_to :changes }
    it { is_expected.to respond_to :created_at }
    it { is_expected.to respond_to :updated_at }
  end
end
