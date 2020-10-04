RSpec.describe Nintendo::JapanClient, type: :client do
  describe 'Configurations' do
    it 'has specific base_uri' do
      expect(described_class.base_uri).to eq 'https://search.nintendo.jp/nintendo_soft'
    end

    it 'has default_params' do
      expect(described_class.default_params).to eq(
        opt_hard: '1_HAC', fq: 'ssitu_s:onsale OR ssitu_s:preorder OR ssitu_s:unreleased', sort: 'sodate desc'
      )
    end
  end

  describe 'Public instance methods' do
    describe '#fetch' do
      let(:response) { Hash[*Faker::Lorem.words(number: 8)] }
      let(:page) { Faker::Number.number(digits: 1) }
      let(:query_params) { described_class.default_params.merge(page: page, limit: 300) }

      before do
        stub_request(:get, "#{described_class.base_uri}/search.json")
          .with(query: query_params)
          .to_return(body: response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'makes request and returns parsed response' do
        result = subject.fetch(page: page)

        expect(result).to eq response
      end
    end
  end
end
