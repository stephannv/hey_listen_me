RSpec.describe RawDataItemRepository, type: :repository do
  describe '#find_by_data_source_and_external_id' do
    let(:raw_data_item_attributes) { attributes_for(:raw_data_item) }

    context 'when a raw_data_item matches data source and external id' do
      before { subject.create(raw_data_item_attributes) }

      it 'returns found raw_data_item' do
        raw_data_item = subject.find_by_data_source_and_external_id(
          raw_data_item_attributes.slice(:data_source, :external_id)
        )

        expect(raw_data_item.to_h).to include(raw_data_item_attributes)
      end
    end

    context 'when none raw_data_item matches data source and external id' do
      it 'returns nil' do
        raw_data_item = subject.find_by_data_source_and_external_id(
          raw_data_item_attributes.slice(:data_source, :external_id)
        )

        expect(raw_data_item).to be_nil
      end
    end
  end

  describe '#not_imported' do
    let!(:imported_raw_data_item) { subject.create(build(:raw_data_item, imported: true)) }
    let!(:not_imported_raw_data_item) { subject.create(build(:raw_data_item, imported: false)) }

    it 'returns not imported raw data items' do
      not_imported = subject.not_imported.to_a

      expect(not_imported).to_not include(imported_raw_data_item)
      expect(not_imported).to include(not_imported_raw_data_item)
    end
  end
end
