RSpec.describe ImportRawInfo, type: :service do
  subject { described_class.new(inputs) }

  let(:raw_info_repository) { RawInfoRepository.new }
  let(:inputs) do
    temp_raw_info = build(:raw_info)
    {
      data_source: temp_raw_info.data_source,
      external_id: temp_raw_info.checksum,
      data: temp_raw_info.data,
      raw_info_repository: raw_info_repository
    }
  end

  describe 'Inputs' do
    subject { described_class.inputs }

    it { is_expected.to include(data_source: { type: String, in: DataSource.list }) }
    it { is_expected.to include(external_id: { type: String }) }
    it { is_expected.to include(data: { type: Hash }) }
    it 'injects raw info repository dependency' do
      expect(subject[:raw_info_repository][:default].call).to be_a(RawInfoRepository)
    end
  end

  describe '#call' do
    context 'when raw_info from given data_source with given external_id isn`t found' do
      before do
        allow(raw_info_repository).to receive(:by_data_source_and_external_id)
          .with(inputs.slice(:data_source, :external_id))
          .and_return(nil)
      end

      it 'creates a raw info' do
        expect(subject).to receive(:create_raw_info).once
        expect(subject).to_not receive(:update_raw_info)

        subject.call
      end
    end

    context 'when raw_info from given data_source with given external_id is found' do
      let(:raw_info) { build(:raw_info) }

      before do
        allow(raw_info_repository).to receive(:by_data_source_and_external_id)
          .with(inputs.slice(:data_source, :external_id))
          .and_return(raw_info)
      end

      it 'updates found raw_info' do
        expect(subject).to receive(:update_raw_info).with(raw_info: raw_info).once
        expect(subject).to_not receive(:create_raw_info)

        subject.call
      end
    end
  end

  describe '#create_info' do
    before do
      allow(subject).to receive(:sorted_data).and_return({ 'sorted' => 'data' })
      allow(subject).to receive(:data_checksum).and_return({ 'sorted' => 'data' }.hash.to_s)
    end

    let(:raw_info) { subject.send(:create_raw_info) }

    it 'creates a new raw_info with inputs data' do
      expect(raw_info.id).to_not be_nil
      expect(raw_info.data_source).to eq inputs[:data_source]
      expect(raw_info.external_id).to eq inputs[:external_id]
      expect(raw_info.data).to eq('sorted' => 'data')
      expect(raw_info.checksum).to eq({ 'sorted' => 'data' }.hash.to_s)
    end
  end

  describe '#update_raw_info' do
    let(:raw_info) { raw_info_repository.create(build(:raw_info)) }

    context 'when data checksum is equal to raw info checksum' do
      before do
        allow(subject).to receive(:data_checksum).and_return(raw_info.checksum)
      end

      it 'does nothing' do
        expect(raw_info_repository).to_not receive(:update)

        expect(subject.send(:update_raw_info, raw_info: raw_info)).to be_nil
      end
    end

    context 'when data checksum is different from raw info checksum' do
      let(:new_checksum) { Faker::Lorem.word }

      before do
        allow(subject).to receive(:data_checksum).and_return(new_checksum)
        allow(subject).to receive(:sorted_data).and_return({ 'sorted' => 'data' })
      end

      it 'updates raw info data and checksum' do
        updated_raw_info = subject.send(:update_raw_info, raw_info: raw_info)

        expect(updated_raw_info.id).to eq raw_info.id
        expect(updated_raw_info.data_source).to eq raw_info.data_source
        expect(updated_raw_info.external_id).to eq raw_info.external_id
        expect(updated_raw_info.checksum).to eq new_checksum
        expect(updated_raw_info.data).to eq({ 'sorted' => 'data' })
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
