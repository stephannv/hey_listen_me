RSpec.describe RawInfoRepository, type: :repository do
  describe '#by_data_source_and_external_id' do
    let(:raw_info_data) { attributes_for(:raw_info) }

    context 'when a raw_info matches data source and external id' do
      it 'returns found raw_info' do
        subject.create(raw_info_data)

        found_raw_info = subject.by_data_source_and_external_id(raw_info_data.slice(:data_source, :external_id))

        expect(found_raw_info.to_h).to include(raw_info_data)
      end
    end

    context 'when none raw_info matches data source and external id' do
      it 'returns nil' do
        expect(subject.by_data_source_and_external_id(raw_info_data.slice(:data_source, :external_id))).to be_nil
      end
    end
  end
end
