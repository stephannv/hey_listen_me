RSpec.describe RawData::CreateChangelog, type: :service do
  subject { described_class.new(inputs) }

  let(:repository) { RawDataChangelogRepository.new }
  let(:raw_data_item_id) { SecureRandom.uuid }
  let(:old_raw_data_item) { build(:raw_data_item, id: raw_data_item_id) }
  let(:new_raw_data_item) { build(:raw_data_item, id: raw_data_item_id) }

  let(:inputs) do
    {
      old_raw_data_item: old_raw_data_item,
      new_raw_data_item: new_raw_data_item,
      raw_data_changelog_repository: repository
    }
  end

  describe 'Inputs' do
    subject { described_class.inputs }

    it { is_expected.to include(old_raw_data_item: { type: RawDataItem, allow_nil: true }) }
    it { is_expected.to include(new_raw_data_item: { type: RawDataItem, allow_nil: true }) }
    it 'injects raw data changelog repository dependency' do
      expect(subject[:raw_data_changelog_repository][:default].call).to be_a(RawDataChangelogRepository)
    end
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to eq({}) }
  end

  describe '#call' do
    context 'when new raw data item isn`t present' do
      let(:new_raw_data_item) { nil }

      it 'does nothing' do
        expect(repository).to_not receive(:create)

        expect(subject.call).to be_nil
      end
    end

    context 'when old raw data item and new raw data item has different ids' do
      let(:old_raw_data_item) { build(:raw_data_item, id: 'abc') }
      let(:new_raw_data_item) { build(:raw_data_item, id: 'def') }

      it 'raises error' do
        expect { subject.call }.to raise_error('DIFFERENT RAW DATA ITEMS')
      end
    end

    context 'when new raw data item is present and have the same id as old raw data item' do
      let(:event_type) { EventType.list.sample }
      let(:changes) { [Faker::Lorem.word] }

      before do
        RawDataItemRepository.new.create(build(:raw_data_item, id: new_raw_data_item.id))
        allow(subject).to receive(:event_type).and_return(event_type)
        allow(subject).to receive(:changes).and_return(changes)
      end

      it 'creates a new changelog' do
        expect(repository).to receive(:create).once.and_call_original

        raw_data_changelog = subject.call

        expect(raw_data_changelog.id).to_not be_nil
        expect(raw_data_changelog.raw_data_item_id).to eq new_raw_data_item.id
        expect(raw_data_changelog.event_type).to eq event_type
        expect(raw_data_changelog.changes).to eq changes
      end
    end
  end

  describe '#event_type' do
    context 'when old raw data item isn`t present' do
      let(:old_raw_data_item) { nil }

      it 'returns create event type' do
        expect(subject.send(:event_type)).to eq EventType::CREATE
      end
    end

    context 'when old raw data item is present' do
      it 'returns update event type' do
        expect(subject.send(:event_type)).to eq EventType::UPDATE
      end
    end
  end

  describe '#changes' do
    let(:old_raw_data_item) { build(:raw_data_item, id: raw_data_item_id, data: { 'a' => 1, 'b' => 1 }) }
    let(:new_raw_data_item) { build(:raw_data_item, id: raw_data_item_id, data: { 'a' => 9, 'b' => 2 }) }

    before { stub_const('IgnoredKeys::LIST', { new_raw_data_item.data_source => [:a] }) }

    it 'returns hash diff ignoring keys present in ignored keys list' do
      expect(subject.send(:changes)).to eq Hashdiff.diff({ 'b' => 1 }, { 'b' => 2 })
    end
  end
end
