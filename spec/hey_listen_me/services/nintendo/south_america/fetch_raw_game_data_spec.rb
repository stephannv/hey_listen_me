RSpec.describe Nintendo::SouthAmerica::FetchRawGameData, type: :service do
  describe 'Inputs' do
    subject { described_class.inputs }

    it 'injects Nintendo South America Game crawer dependency' do
      expect(subject[:crawler][:default].call).to be_a(Nintendo::SouthAmericaGameCrawler)
    end
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to include(data_source: { type: String }) }
    it { is_expected.to include(external_id_key: { type: String }) }
    it { is_expected.to include(raw_data: { type: Array }) }
  end

  describe '#call' do
    let(:crawler) { Nintendo::SouthAmericaGameCrawler.new }
    let(:response) { [Faker::Lorem.word] }

    subject { described_class.call(crawler: crawler) }

    before do
      allow(crawler).to receive(:crawl).with(country: :brasil).and_return(response)
      expect(crawler).to receive(:crawl).once
    end

    it 'outputs raw_data with all data crawled from Nintendo south america website' do
      expect(subject.raw_data).to eq(response)
    end

    it 'outputs id_key, platform_id and region_id related with Nintendo South America data' do
      expect(subject.data_source).to eq DataSource::NINTENDO_BRASIL
      expect(subject.external_id_key).to eq 'provider_identifier'
    end
  end
end
