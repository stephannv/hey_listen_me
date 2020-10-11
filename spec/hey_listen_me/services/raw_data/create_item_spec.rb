RSpec.describe RawData::CreateItem, type: :service do
  subject { described_class.new(inputs) }

  let(:raw_data_item_repository) { RawDataItemRepository.new }
  let(:inputs) do
    temp_raw_data_item = build(:raw_data_item)
    {
      data_source: temp_raw_data_item.data_source,
      external_id: temp_raw_data_item.checksum,
      data: temp_raw_data_item.data,
      repository: raw_data_item_repository
    }
  end

  describe 'Inputs' do
    subject { described_class.inputs }

    it { is_expected.to include(data_source: { type: String, in: DataSource.list }) }
    it { is_expected.to include(external_id: { type: String }) }
    it { is_expected.to include(data: { type: Hash }) }
    it 'injects raw data item repository dependency' do
      expect(subject[:repository][:default].call).to be_a(RawDataItemRepository)
    end
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to include(old_raw_data_item: { type: RawDataItem, allow_nil: true }) }
    it { is_expected.to include(new_raw_data_item: { type: RawDataItem, allow_nil: true }) }
  end

  describe '#call' do
    context 'when raw_data_item from given data_source with given external_id isn`t found' do
      before do
        allow(raw_data_item_repository).to receive(:by_data_source_and_external_id)
          .with(inputs.slice(:data_source, :external_id))
          .and_return(nil)
      end

      it 'creates a raw data item' do
        expect(subject).to receive(:create_raw_data_item).once
        expect(subject).to_not receive(:update_raw_data_item)

        subject.call
      end
    end

    context 'when raw_data_item from given data_source with given external_id is found' do
      let(:raw_data_item) { build(:raw_data_item) }

      before do
        allow(raw_data_item_repository).to receive(:by_data_source_and_external_id)
          .with(inputs.slice(:data_source, :external_id))
          .and_return(raw_data_item)
      end

      it 'updates found raw_data_item' do
        expect(subject).to receive(:update_raw_data_item).with(raw_data_item: raw_data_item).once
        expect(subject).to_not receive(:create_raw_data_item)

        subject.call
      end
    end
  end

  describe '#create_raw_data_item' do
    before do
      allow(subject).to receive(:sorted_data).and_return({ 'sorted' => 'data' })
      allow(subject).to receive(:data_checksum).and_return({ 'sorted' => 'data' }.hash.to_s)
    end

    let(:raw_data_item) { subject.send(:create_raw_data_item) }

    it 'creates a new raw_data_item with inputs data' do
      expect(raw_data_item.id).to_not be_nil
      expect(raw_data_item.data_source).to eq inputs[:data_source]
      expect(raw_data_item.external_id).to eq inputs[:external_id]
      expect(raw_data_item.data).to eq('sorted' => 'data')
      expect(raw_data_item.checksum).to eq({ 'sorted' => 'data' }.hash.to_s)
      expect(raw_data_item.imported).to eq false
    end
  end

  describe '#update_raw_data_item' do
    let(:raw_data_item) { raw_data_item_repository.create(build(:raw_data_item)) }

    context 'when data checksum is equal to raw data item checksum' do
      before do
        allow(subject).to receive(:data_checksum).and_return(raw_data_item.checksum)
      end

      it 'does nothing' do
        expect(raw_data_item_repository).to_not receive(:update)

        expect(subject.send(:update_raw_data_item, raw_data_item: raw_data_item)).to be_nil
      end
    end

    context 'when data checksum is different from raw data item checksum' do
      let(:new_checksum) { Faker::Lorem.word }

      before do
        allow(subject).to receive(:data_checksum).and_return(new_checksum)
        allow(subject).to receive(:sorted_data).and_return({ 'sorted' => 'data' })
      end

      it 'updates raw data item data and checksum' do
        updated_raw_data_item = subject.send(:update_raw_data_item, raw_data_item: raw_data_item)

        expect(updated_raw_data_item.id).to eq raw_data_item.id
        expect(updated_raw_data_item.data_source).to eq raw_data_item.data_source
        expect(updated_raw_data_item.external_id).to eq raw_data_item.external_id
        expect(updated_raw_data_item.checksum).to eq new_checksum
        expect(updated_raw_data_item.data).to eq({ 'sorted' => 'data' })
        expect(updated_raw_data_item.imported).to eq false
      end
    end
  end

  describe '#sorted_data' do
    before { subject.instance_variable_set('@sorted_data', sorted_data) }

    context 'when @sorted_data has value' do
      let(:sorted_data) { { 'sorted' => 'data' } }

      it 'returns @sorted_data' do
        expect(subject.send(:sorted_data)).to eq(sorted_data)
      end
    end

    context 'when @sorted_data hasn`t value' do
      let(:sorted_data) { nil }

      before do
        allow(subject).to receive(:data).and_return(a: 1, b: [3, 2])
      end

      it 'deep sorts data and sets value to @sorted_data' do
        expected_response = { a: 1, b: [2, 3] }

        expect(subject.send(:sorted_data)).to eq expected_response
        expect(subject.instance_variable_get('@sorted_data')).to eq expected_response
      end
    end
  end

  describe '#data_checksum' do
    before { subject.instance_variable_set('@data_checksum', data_checksum) }

    context 'when @data_checksum has value' do
      let(:data_checksum) { Faker::Lorem.word }

      it 'returns @data_checksum' do
        expect(subject.send(:data_checksum)).to eq data_checksum
      end
    end

    context 'when @data_checksum hasn`t value' do
      let(:data_checksum) { nil }
      let(:ignored_keys) { [:a] }
      let(:sorted_data) { { a: 1, b: [2, 3] } }

      before do
        allow(subject).to receive(:sorted_data).and_return(a: 1, b: [2, 3])
        stub_const('IgnoredKeys::LIST', { inputs[:data_source] => ignored_keys })
      end

      it 'builds a hash from sorted_data ignoring given keys and sets value to @data_checksum' do
        expected_checksum = Digest::MD5.hexdigest(sorted_data.except(*ignored_keys).to_s)
        expect(subject.send(:data_checksum)).to eq expected_checksum
      end
    end
  end
end
