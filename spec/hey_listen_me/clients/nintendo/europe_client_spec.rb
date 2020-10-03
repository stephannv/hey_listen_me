RSpec.describe Nintendo::EuropeClient, type: :client do
  describe 'Configurations' do
    it 'has specific base_uri' do
      expect(described_class.base_uri).to eq 'https://searching.nintendo-europe.com/en'
    end

    it 'has default_params' do
      expect(described_class.default_params).to eq(q: '*', sort: 'date_from desc', fq: 'originally_for_t:HAC')
    end
  end

  describe 'Public instance methods' do
    describe '#fetch' do
      let(:response) { Hash[*Faker::Lorem.words(number: 8)] }
      let(:page) { Faker::Number.number(digits: 1) }
      let(:per_page) { Faker::Number.number(digits: 3) }
      let(:pagination_params) { { start: per_page * (page - 1), rows: per_page } }
      let(:query_params) { described_class.default_params.merge(pagination_params) }

      before do
        stub_request(:get, "#{described_class.base_uri}/select")
          .with(query: query_params)
          .to_return(body: response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'makes request and returns parsed response' do
        result = subject.fetch(page: page, per_page: per_page)

        expect(result).to eq response
      end
    end
  end
end
