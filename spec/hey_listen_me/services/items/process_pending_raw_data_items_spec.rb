RSpec.describe Items::ProcessPendingRawDataItems, type: :service do
  subject { described_class.new(inputs) }

  let(:raw_data_item_repository) { RawDataItemRepository.new }
  let(:inputs) { { raw_data_item_repository: raw_data_item_repository } }

  describe 'Inputs' do
    subject { described_class.inputs }

    it 'injects raw data item repository dependency' do
      expect(subject[:raw_data_item_repository][:default].call).to be_a(RawDataItemRepository)
    end
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to eq({}) }
  end

  describe '#call' do
    let(:raw_data_item_1) { double }
    let(:raw_data_item_2) { double }

    before do
      allow(raw_data_item_repository).to receive(:not_imported).and_return([raw_data_item_1, raw_data_item_2])
    end

    it 'processes each raw data item' do
      expect(Items::ProcessRawDataItem).to receive(:call).with(raw_data_item: raw_data_item_1).once
      expect(Items::ProcessRawDataItem).to receive(:call).with(raw_data_item: raw_data_item_2).once

      subject.call
    end
  end
end
