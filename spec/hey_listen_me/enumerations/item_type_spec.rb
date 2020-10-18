RSpec.describe ItemType, type: :enumeration do
  subject { described_class.list }

  it { is_expected.to include('game') }
  it { is_expected.to include('dlc') }
  it { is_expected.to include('bundle') }
  it { is_expected.to include('voucher') }
  it { is_expected.to include('subscription') }
end
