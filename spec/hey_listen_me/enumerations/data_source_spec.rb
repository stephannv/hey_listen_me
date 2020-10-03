RSpec.describe DataSource, type: :enumeration do
  subject { described_class.list }

  it { is_expected.to include('nintendo_europe') }
  it { is_expected.to include('nintendo_japan') }
  it { is_expected.to include('nintendo_north_america') }
  it { is_expected.to include('nintendo_brasil') }
end
