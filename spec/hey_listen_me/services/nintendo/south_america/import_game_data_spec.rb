RSpec.describe Nintendo::SouthAmerica::ImportGameData, type: :service do
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
      is_expected.to contain_exactly(
        Nintendo::SouthAmerica::FetchGameData,
        ProcessRawInfos
      )
    end
  end
end
