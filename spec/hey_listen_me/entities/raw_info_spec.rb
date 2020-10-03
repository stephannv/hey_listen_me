RSpec.describe RawInfo, type: :entity do
  describe 'Attributes' do
    it { is_expected.to respond_to :id }
    it { is_expected.to respond_to :data_source }
    it { is_expected.to respond_to :external_id }
    it { is_expected.to respond_to :data }
    it { is_expected.to respond_to :checksum }
    it { is_expected.to respond_to :created_at }
    it { is_expected.to respond_to :updated_at }
  end
end
