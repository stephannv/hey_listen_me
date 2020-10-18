RSpec.describe DataAdapters, type: :utils do
  describe 'Constants' do
    describe 'LIST' do
      it 'returns data adapters for each data source' do
        expect(described_class::LIST).to eq(
          'nintendo_europe' => Nintendo::EuropeDataAdapter,
          'nintendo_japan' => Nintendo::JapanDataAdapter,
          'nintendo_north_america' => Nintendo::NorthAmericaDataAdapter,
          'nintendo_brasil' => Nintendo::SouthAmericaDataAdapter
        )
      end
    end
  end
end
