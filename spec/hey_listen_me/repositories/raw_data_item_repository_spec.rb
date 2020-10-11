RSpec.describe RawDataItemRepository, type: :repository do
  describe '#by_data_source_and_external_id' do
    let(:raw_data_item_attributes) { attributes_for(:raw_data_item) }

    context 'when a raw_data_item matches data source and external id' do
      before { subject.create(raw_data_item_attributes) }

      it 'returns found raw_data_item' do
        raw_data_item = subject.by_data_source_and_external_id(
          raw_data_item_attributes.slice(:data_source, :external_id)
        )

        expect(raw_data_item.to_h).to include(raw_data_item_attributes)
      end
    end

    context 'when none raw_data_item matches data source and external id' do
      it 'returns nil' do
        raw_data_item = subject.by_data_source_and_external_id(
          raw_data_item_attributes.slice(:data_source, :external_id)
        )

        expect(raw_data_item).to be_nil
      end
    end
  end
end
