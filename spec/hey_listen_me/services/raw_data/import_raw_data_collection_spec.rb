RSpec.describe RawData::ImportRawDataCollection, type: :service do
  subject { described_class.new(inputs) }

  describe 'Inputs' do
    subject { described_class.inputs }

    it { is_expected.to include(data_source: { type: String, in: DataSource.list }) }
    it { is_expected.to include(external_id_key: { type: String }) }
    it { is_expected.to include(raw_data: { type: Array }) }
  end

  describe '#call' do
    let(:data_source) { DataSource.list.sample }
    let(:raw_data_1) { { 'nsuid' => 'abc', 'a' => '1', 'b' => '2' } }
    let(:raw_data_2) { { 'nsuid' => 'def', 'a' => '3', 'b' => '4' } }
    let(:keys) { [Faker::Lorem.word, Faker::Lorem.word] }
    let(:inputs) do
      {
        data_source: data_source,
        external_id_key: 'nsuid',
        raw_data: [raw_data_1, raw_data_2]
      }
    end

    it 'import each raw data' do
      expect(RawData::ImportRawDataItem).to receive(:call)
        .with(data_source: data_source, external_id: 'abc', data: raw_data_1)
        .once
      expect(RawData::ImportRawDataItem).to receive(:call)
        .with(data_source: data_source, external_id: 'def', data: raw_data_2)
        .once

      subject.call
    end
  end
end
