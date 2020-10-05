RSpec.describe Nintendo::NorthAmericaClient, type: :clients do
  describe 'Constants' do
    it 'has APPLICATION_ID constant' do
      expect(described_class::APPLICATION_ID).to eq ENV['NINTENDO_NORTH_AMERICA_APPLICATION_ID']
    end

    it 'has API_KEY constant' do
      expect(described_class::API_KEY).to eq ENV['NINTENDO_NORTH_AMERICA_API_KEY']
    end
  end

  describe 'Instance methods' do
    describe '#fetch' do
      let(:index) { subject.index_desc }
      let(:hits) { [double] }
      let(:response) { { 'hits' => hits } }
      let(:query) { Faker::Lorem.word }

      before do
        allow(index).to receive(:search)
          .with(query, queryType: 'prefixAll', hitsPerPage: 1000, filters: 'platform:"Nintendo Switch"')
          .and_return(response)
      end

      it 'returns hits from search result' do
        expect(subject.fetch(index: index, query: query)).to eq hits
      end
    end

    describe '#index_asc' do
      subject { described_class.new(client: client) }

      let(:client) { double }
      let(:index) { double }

      context 'when @index_asc is nil' do
        before do
          subject.instance_variable_set('@index_asc', nil)
          allow(client).to receive(:init_index).with('noa_aem_game_en_us_title_asc').and_return(index)
        end

        it 'returns a algolia index with release date desc' do
          expect(subject.index_asc).to eq index
        end
      end

      context 'when @index_asc isn`t nil' do
        before do
          subject.instance_variable_set('@index_asc', index)
        end

        it 'returns @index_asc' do
          expect(client).to_not receive(:init_index)
          expect(subject.index_asc).to eq index
        end
      end
    end

    describe '#index_desc' do
      subject { described_class.new(client: client) }

      let(:client) { double }
      let(:index) { double }

      context 'when @index_desc is nil' do
        before do
          subject.instance_variable_set('@index_desc', nil)
          allow(client).to receive(:init_index).with('noa_aem_game_en_us_title_des').and_return(index)
        end

        it 'returns a algolia index with release date desc' do
          expect(subject.index_desc).to eq index
        end
      end

      context 'when @index_desc isn`t nil' do
        before do
          subject.instance_variable_set('@index_desc', index)
        end

        it 'returns @index_desc' do
          expect(client).to_not receive(:init_index)
          expect(subject.index_desc).to eq index
        end
      end
    end
  end
end
