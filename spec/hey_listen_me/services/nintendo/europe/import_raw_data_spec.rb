RSpec.describe Nintendo::Europe::ImportRawData, type: :service do
  describe 'Inputs' do
    subject { described_class.inputs }

    it { is_expected.to eq({}) }
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to eq({}) }
  end

  describe 'Play actors' do
    subject { described_class.play_actors.map(&:values).flatten }

    it do
      is_expected.to contain_exactly(Nintendo::Europe::FetchRawData, RawData::ImportRawDataCollection)
    end
  end
end
