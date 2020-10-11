RSpec.describe Nintendo::NorthAmerica::FetchRawData, type: :service do
  describe 'Inputs' do
    subject { described_class.inputs }

    it 'injects Nintendo North America client dependency' do
      expect(subject[:client][:default].call).to be_a(Nintendo::NorthAmericaClient)
    end
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to include(data_source: { type: String }) }
    it { is_expected.to include(external_id_key: { type: String }) }
    it { is_expected.to include(raw_data: { type: Array }) }
  end

  describe '#call' do
    let(:raw_data) { [] }

    subject { described_class.call }

    before do
      (('a'..'z').to_a + ('0'..'9').to_a).each do |query|
        result = { 'objectID' => Faker::Lorem.word, '_highlightResult' => {} }
        allow_any_instance_of(described_class).to receive(:fetch_data).with(query: query).and_return([result])
        raw_data << result
      end
    end

    it 'outputs raw_data with all data from all pages from Nintendo North America client' do
      expected_result = raw_data.flatten.uniq { |d| d['objectID'] }.map { |d| d.except('_highlightResult') }
      expect(subject.raw_data).to eq expected_result
    end

    it 'outputs id_key, platform_id and region_id related with Nintendo North America data' do
      expect(subject.data_source).to eq DataSource::NINTENDO_NORTH_AMERICA
      expect(subject.external_id_key).to eq 'objectID'
    end
  end

  describe '#fetch_data' do
    let(:client) { Nintendo::NorthAmericaClient.new }

    subject { described_class.new(client: client) }

    let(:response) { (1..999).to_a }
    let(:query) { Faker::Lorem.word }

    before do
      allow(client).to receive(:fetch)
        .with(index: client.index_asc, query: query)
        .and_return(response)

      allow(client).to receive(:fetch)
        .with(index: client.index_desc, query: query)
        .and_return((1001..1050).to_a)
    end

    it 'fetches using desc index and given filter' do
      expect(subject.send(:fetch_data, query: query)).to eq response
    end

    context 'when first fetch returns 1000 items or more' do
      let(:response) { (1..1000).to_a }

      it 'fetches again using asc index' do
        expect(subject.send(:fetch_data, query: query)).to eq((1..1050).to_a)
      end
    end
  end
end
