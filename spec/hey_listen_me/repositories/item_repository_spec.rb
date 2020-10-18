RSpec.describe ItemRepository, type: :repository do
  describe '#find_by_raw_data_item_id' do
    context 'when there is a item with given raw_data_item_id' do
      let(:raw_data_item) { RawDataItemRepository.new.create(build(:raw_data_item)) }
      let!(:item) { subject.create(build(:item, raw_data_item_id: raw_data_item.id)) }

      it 'returns item' do
        expect(subject.find_by_raw_data_item_id(raw_data_item.id)).to eq item
      end
    end

    context 'when there isn`t a item with given raw_data_item_id' do
      let(:raw_data_item) { RawDataItemRepository.new.create(build(:raw_data_item)) }

      it 'returns nil' do
        expect(subject.find_by_raw_data_item_id(raw_data_item.id)).to be_nil
      end
    end
  end
end
