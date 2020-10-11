RSpec.describe Nintendo::Japan::FetchRawData, type: :service do
  describe 'Inputs' do
    subject { described_class.inputs }

    it 'injects Nintendo Japan client dependency' do
      expect(subject[:client][:default].call).to be_a(Nintendo::JapanClient)
    end
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to include(data_source: { type: String }) }
    it { is_expected.to include(external_id_key: { type: String }) }
    it { is_expected.to include(raw_data: { type: Array }) }
  end

  describe '#call' do
    let!(:client) { Nintendo::JapanClient.new }

    let(:response_1) { [Faker::Lorem.word] }
    let(:response_2) { [Faker::Lorem.word] }
    let(:response_3) { nil }

    subject { described_class.call(client: client) }

    before do
      allow(client).to receive(:fetch).with(page: 1).and_return('result' => { 'items' => response_1 })
      allow(client).to receive(:fetch).with(page: 2).and_return('result' => { 'items' => response_2 })
      allow(client).to receive(:fetch).with(page: 3).and_return('result' => { 'items' => response_3 })

      expect(client).to receive(:fetch).exactly(3).times
    end

    it 'outputs raw_data with all data from all pages from Nintendo Japan client' do
      expect(subject.raw_data).to eq(response_1 + response_2)
    end

    it 'outputs id_key, platform_id and region_id related with Nintendo Japan data' do
      expect(subject.data_source).to eq DataSource::NINTENDO_JAPAN
      expect(subject.external_id_key).to eq 'id'
    end
  end
end
