RSpec.describe RegisterEvent, type: :service do
  subject { described_class.new(inputs) }

  let(:repository) { EventRepository.new }
  let(:raw_info_id) { SecureRandom.uuid }
  let(:old_raw_info) { build(:raw_info, id: raw_info_id) }
  let(:new_raw_info) { build(:raw_info, id: raw_info_id) }

  let(:inputs) { { old_raw_info: old_raw_info, new_raw_info: new_raw_info, event_repository: repository } }

  describe 'Inputs' do
    subject { described_class.inputs }

    it { is_expected.to include(old_raw_info: { type: RawInfo, allow_nil: true }) }
    it { is_expected.to include(new_raw_info: { type: RawInfo, allow_nil: true }) }
    it 'injects event repository dependency' do
      expect(subject[:event_repository][:default].call).to be_a(EventRepository)
    end
  end

  describe 'Outputs' do
    subject { described_class.outputs }

    it { is_expected.to eq({}) }
  end

  describe '#call' do
    context 'when new raw info isn`t present' do
      let(:new_raw_info) { nil }

      it 'does nothing' do
        expect(repository).to_not receive(:create)

        expect(subject.call).to be_nil
      end
    end

    context 'when old raw info and new raw info has different ids' do
      let(:old_raw_info) { build(:raw_info, id: 'abc') }
      let(:new_raw_info) { build(:raw_info, id: 'def') }

      it 'raises error' do
        expect { subject.call }.to raise_error('DIFFERENT RAW INFOS')
      end
    end

    context 'when new raw info is present and old raw info and new raw info has the same id' do
      let(:event_type) { EventType.list.sample }
      let(:changes) { [Faker::Lorem.word] }

      before do
        RawInfoRepository.new.create(build(:raw_info, id: new_raw_info.id))
        allow(subject).to receive(:event_type).and_return(event_type)
        allow(subject).to receive(:changes).and_return(changes)
      end

      it 'creates a new event' do
        expect(repository).to receive(:create).once.and_call_original

        event = subject.call

        expect(event.id).to_not be_nil
        expect(event.raw_info_id).to eq new_raw_info.id
        expect(event.type).to eq event_type
        expect(event.changes).to eq changes
      end
    end
  end

  describe '#event_type' do
    context 'when old raw info isn`t present' do
      let(:old_raw_info) { nil }

      it 'returns create event type' do
        expect(subject.send(:event_type)).to eq EventType::CREATE
      end
    end

    context 'when old raw info is present' do
      it 'returns update event type' do
        expect(subject.send(:event_type)).to eq EventType::UPDATE
      end
    end
  end

  describe '#changes' do
    let(:old_raw_info) { build(:raw_info, id: raw_info_id, data: { 'a' => 1, 'b' => 1 }) }
    let(:new_raw_info) { build(:raw_info, id: raw_info_id, data: { 'a' => 9, 'b' => 2 }) }

    before { stub_const('IgnoredKeys::LIST', { new_raw_info.data_source => [:a] }) }

    it 'returns hash diff ignoring keys present in ignored keys list' do
      expect(subject.send(:changes)).to eq Hashdiff.diff({ 'b' => 1 }, { 'b' => 2 })
    end
  end
end
