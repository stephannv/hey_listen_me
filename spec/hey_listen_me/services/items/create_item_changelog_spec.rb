RSpec.describe Items::CreateItemChangelog, type: :service do
  subject { described_class.new(inputs) }

  let(:item_changelog_repository) { ItemChangelogRepository.new }
  let(:item_id) { SecureRandom.uuid }
  let(:old_item) { build(:item, id: item_id) }
  let(:new_item) { build(:item, id: item_id) }

  let(:inputs) do
    {
      old_item: old_item,
      new_item: new_item,
      item_changelog_repository: item_changelog_repository
    }
  end

  describe 'Inputs' do
    subject { described_class.inputs }

    it { is_expected.to include(old_item: { type: Item, allow_nil: true }) }
    it { is_expected.to include(new_item: { type: Item, allow_nil: true }) }
    it 'injects item changelog repository dependency' do
      expect(subject[:item_changelog_repository][:default].call).to be_a(ItemChangelogRepository)
    end
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to eq({}) }
  end

  describe '#call' do
    context 'when new item isn`t present' do
      let(:new_item) { nil }

      it 'does nothing' do
        expect(item_changelog_repository).to_not receive(:create)

        expect(subject.call).to be_nil
      end
    end

    context 'when old item and new item has different ids' do
      let(:old_item) { build(:item, id: 'abc') }
      let(:new_item) { build(:item, id: 'def') }

      it 'raises error' do
        expect { subject.call }.to raise_error('DIFFERENT ITEMS')
      end
    end

    context 'when new item is present and have the same id as old item' do
      let(:event_type) { EventType.list.sample }
      let(:changes) { Hashdiff.diff(old_item.data.to_h, new_item.data.to_h) }

      before do
        raw_data_item = RawDataItemRepository.new.create(build(:raw_data_item))
        ItemRepository.new.create(build(:item, id: new_item.id, raw_data_item_id: raw_data_item.id))
        allow(subject).to receive(:event_type).and_return(event_type)
      end

      it 'creates a new item changelog' do
        expect(item_changelog_repository).to receive(:create).once.and_call_original

        item_changelog = subject.call

        expect(item_changelog.id).to_not be_nil
        expect(item_changelog.item_id).to eq new_item.id
        expect(item_changelog.event_type).to eq event_type
        expect(item_changelog.changes).to eq changes
      end
    end
  end

  describe '#event_type' do
    context 'when old item isn`t present' do
      let(:old_item) { nil }

      it 'returns create event type' do
        expect(subject.send(:event_type)).to eq EventType::CREATE
      end
    end

    context 'when old item is present' do
      it 'returns update event type' do
        expect(subject.send(:event_type)).to eq EventType::UPDATE
      end
    end
  end
end
