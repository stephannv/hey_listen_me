RSpec.describe IgnoredKeys, type: :utils do
  describe 'Constants' do
    describe 'LIST' do
      it 'returns ignored keys for each data source' do
        expect(described_class::LIST['nintendo_europe']).to eq %w[
          _version_
          popularity
          price_regular_f
          price_discount_percentage_f
          price_has_discount_b
          price_lowest_f
          price_sorting_f
          price_discounted_f
        ]

        expect(described_class::LIST['nintendo_japan']).to eq %w[score current_price drate sale_flg]
        expect(described_class::LIST['nintendo_north_america']).to eq []
        expect(described_class::LIST['nintendo_brasil']).to eq []
      end
    end
  end
end
