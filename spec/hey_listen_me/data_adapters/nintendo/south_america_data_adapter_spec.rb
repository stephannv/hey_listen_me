RSpec.describe Nintendo::SouthAmericaDataAdapter, type: :data_adapter do
  describe '#adapt' do
    subject { described_class.new(data).adapt }

    let(:data) { { 'platform' => 'Nintendo Switch', 'type' => 'game' } }

    it 'returns @data' do
      expect(subject).to eq data
    end
  end
end
