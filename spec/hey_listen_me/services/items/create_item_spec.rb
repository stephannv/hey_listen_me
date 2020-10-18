RSpec.describe Items::CreateItem, type: :service do
  subject { described_class.new(inputs) }

  let(:item_repository) { ItemRepository.new }
  let(:raw_data_item_repository) { RawDataItemRepository.new }
  let(:raw_data_item) { raw_data_item_repository.create(build(:raw_data_item, imported: false)) }
  let(:inputs) do
    {
      raw_data_item: raw_data_item,
      item_repository: item_repository,
      raw_data_item_repository: raw_data_item_repository
    }
  end

  describe 'Inputs' do
    subject { described_class.inputs }

    it { is_expected.to include(raw_data_item: { type: RawDataItem }) }
    it 'injects  item repository dependency' do
      expect(subject[:item_repository][:default].call).to be_a(ItemRepository)
    end
    it 'injects raw data item repository dependency' do
      expect(subject[:raw_data_item_repository][:default].call).to be_a(RawDataItemRepository)
    end
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to include(old_item: { type: Item, allow_nil: true }) }
    it { is_expected.to include(new_item: { type: Item, allow_nil: true }) }
  end

  describe '#call' do
    context 'when item from with given raw_data_item_id isn`t found' do
      before do
        allow(item_repository).to receive(:find_by_raw_data_item_id)
          .with(raw_data_item.id)
          .and_return(nil)
      end

      it 'creates a raw data item' do
        expect(subject).to receive(:create_item).once
        expect(subject).to_not receive(:update_item)

        subject.call
      end
    end

    context 'when item with given raw_data_item_id is found' do
      let(:item) { build(:item) }

      before do
        allow(item_repository).to receive(:find_by_raw_data_item_id)
          .with(raw_data_item.id)
          .and_return(item)
      end

      it 'updates found raw_data_item' do
        expect(subject).to receive(:update_item).with(item).once
        expect(subject).to_not receive(:create_item)

        subject.call
      end
    end

    it 'sets raw_data_item as imported' do
      allow(subject).to receive(:create_item).and_return(true)
      expect(raw_data_item_repository).to receive(:update).with(raw_data_item.id, { imported: true })

      subject.call
    end
  end

  describe '#create_item' do
    before do
      allow(subject).to receive(:parsed_data).and_return({ 'parsed' => 'data' })
      allow(subject).to receive(:parsed_data_checksum).and_return({ 'parsed' => 'data' }.hash.to_s)
    end

    let(:item) { subject.send(:create_item) }

    it 'creates a new item with inputs data' do
      expect(item.id).to_not be_nil
      expect(item.data_source).to eq raw_data_item.data_source
      expect(item.raw_data_item_id).to eq raw_data_item.id
      expect(item.data).to eq('parsed' => 'data')
      expect(item.checksum).to eq({ 'parsed' => 'data' }.hash.to_s)
    end
  end

  describe '#update_item' do
    let(:item) { item_repository.create(build(:item, raw_data_item_id: raw_data_item.id)) }

    context 'when parsed data checksum is equal to item checksum' do
      before do
        allow(subject).to receive(:parsed_data_checksum).and_return(item.checksum)
      end

      it 'does nothing' do
        expect(item_repository).to_not receive(:update)

        expect(subject.send(:update_item, item)).to be_nil
      end
    end

    context 'when parsed data checksum is different from raw data item checksum' do
      let(:new_checksum) { Faker::Lorem.word }

      before do
        allow(subject).to receive(:parsed_data_checksum).and_return(new_checksum)
        allow(subject).to receive(:parsed_data).and_return({ 'parse' => 'data' })
      end

      it 'updates raw data item data and checksum' do
        updated_item = subject.send(:update_item, item)

        expect(updated_item.id).to eq item.id
        expect(updated_item.checksum).to eq new_checksum
        expect(updated_item.data).to eq({ 'parse' => 'data' })
      end
    end
  end

  describe '#parsed_data' do
    before { subject.instance_variable_set('@parsed_data', parsed_data) }

    context 'when @parsed_data has value' do
      let(:parsed_data) { { 'parse' => 'data' } }

      it 'returns @parsed_data' do
        expect(subject.send(:parsed_data)).to eq(parsed_data)
      end
    end

    context 'when @parsed_data hasn`t value' do
      let(:parsed_data) { nil }
      let(:data_adapter) { DataAdapters::LIST[raw_data_item.data_source] }
      let(:raw_data_item) do
        raw_data_item_repository.create(build(:raw_data_item, data: { a: 1, b: [3, 2] }, imported: false))
      end

      it 'deep sorts adapted data and sets value to @parsed_data' do
        expected_response = { a: 1, b: [2, 3] }

        allow_any_instance_of(data_adapter).to receive(:adapt).and_return(expected_response)
        expect(subject.send(:parsed_data)).to eq expected_response
        expect(subject.instance_variable_get('@parsed_data')).to eq expected_response
      end
    end
  end

  describe '#parsed_data_checksum' do
    before { subject.instance_variable_set('@parsed_data_checksum', parsed_data_checksum) }

    context 'when @parsed_data_checksum has value' do
      let(:parsed_data_checksum) { Faker::Lorem.word }

      it 'returns @parsed_data_checksum' do
        expect(subject.send(:parsed_data_checksum)).to eq parsed_data_checksum
      end
    end

    context 'when @parsed_data_checksum hasn`t value' do
      let(:parsed_data_checksum) { nil }
      let(:parsed_data) { { a: 1, b: [2, 3] } }

      before do
        allow(subject).to receive(:parsed_data).and_return(a: 1, b: [2, 3])
      end

      it 'builds a hash from parsed_data and sets value to @parsed_data_checksum' do
        expected_checksum = Digest::MD5.hexdigest(parsed_data.to_s)
        expect(subject.send(:parsed_data_checksum)).to eq expected_checksum
      end
    end
  end
end
