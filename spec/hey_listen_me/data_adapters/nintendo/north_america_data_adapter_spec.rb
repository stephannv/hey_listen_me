RSpec.describe Nintendo::NorthAmericaDataAdapter, type: :data_adapter do
  describe 'Adapted fields' do
    subject { described_class.new(base_data.merge(data)).adapt }

    let(:data) { {} }
    let(:base_data) { { 'platform' => 'Nintendo Switch', 'type' => 'game' } }

    describe '#platform' do
      context 'when platform is Nintendo Switch' do
        let(:data) { {  'platform' => 'Nintendo Switch' } }

        it 'return NSW' do
          expect(subject[:platform]).to eq 'nintendo_switch'
        end
      end

      context 'when platform isn`t mapped' do
        let(:data) { { 'platform' => Faker::Lorem.word } }

        it 'raises error' do
          expect { subject }.to raise_error("#{data['platform']} - NOT MAPPED PLATFORM")
        end
      end
    end

    describe '#data_source' do
      it 'returns `north_america`' do
        expect(subject[:data_source]).to eq DataSource::NINTENDO_NORTH_AMERICA
      end
    end

    describe '#item_type' do
      it 'returns ItemType::GAME' do
        expect(subject[:item_type]).to eq ItemType::GAME
      end
    end

    describe '#title' do
      context 'when title is present' do
        let(:title) { Faker::Lorem.word }
        let(:data) { { 'title' => "#{title}®™" } }

        it 'returns title without ® ™ symbols' do
          expect(subject[:title]).to eq title
        end
      end

      context 'when title isn`t present' do
        let(:data) { { 'title' => nil } }

        it 'returns nil' do
          expect(subject[:title]).to be_nil
        end
      end
    end

    describe '#long_description' do
      let(:data) { { 'description' => Faker::Lorem.word } }

      it 'returns description content' do
        expect(subject[:long_description]).to eq data['description']
      end
    end

    describe '#release_date' do
      context 'when releaseDateDisplay is a valid date' do
        let(:data) { { 'releaseDateDisplay' => (Date.today - 1).to_s } }

        it 'returns releaseDateDisplay converted to date' do
          expect(subject[:release_date]).to eq(Date.today - 1)
        end
      end

      context 'when releaseDateDisplay isn`t valid' do
        let(:data) { { 'releaseDateDisplay' => Faker::Lorem.word } }

        it 'returns 2049-12-31' do
          expect(subject[:release_date]).to eq Date.parse('31/12/2049')
        end
      end
    end

    describe '#release_date_text' do
      context 'when releaseDateDisplay is a valid date' do
        let(:data) { { 'releaseDateDisplay' => (Date.today - 1).to_s } }

        it 'returns releaseDateDisplay converted to date' do
          expect(subject[:release_date_text]).to eq (Date.today - 1).to_s
        end
      end

      context 'when releaseDateDisplay isn`t valid' do
        let(:data) { { 'releaseDateDisplay' => Faker::Lorem.word } }

        it 'returns releaseDateDisplay' do
          expect(subject[:release_date_text]).to eq data['releaseDateDisplay']
        end
      end
    end

    describe '#website_url' do
      let(:data) { { 'url' => Faker::Lorem.word } }

      it 'adds nintendo america domain as prefix to url' do
        expect(subject[:website_url]).to eq "https://www.nintendo.com#{data['url']}"
      end
    end

    describe '#main_image_url' do
      let(:data) { { 'boxart' => Faker::Lorem.word } }

      it 'adds nintendo america domain as prefix to boxart' do
        expect(subject[:main_image_url]).to eq "https://www.nintendo.com#{data['boxart']}"
      end
    end

    describe '#provider_identifier' do
      let(:data) { { 'nsuid' => Faker::Lorem.word } }

      it 'returns nsuid' do
        expect(subject[:provider_identifier]).to eq data['nsuid']
      end
    end

    describe '#provider_identifiers' do
      let(:objectID) { Faker::Lorem.word }
      let(:nsuid) { [Faker::Lorem.word, nil] }
      let(:data) { { 'objectID' => objectID, 'nsuid' => nsuid } }

      it 'returns objectID and nsuid flattened and compacted' do
        expect(subject[:provider_identifiers]).to eq [nsuid, objectID].flatten.compact
      end
    end

    describe '#categories' do
      context 'when categories is present' do
        let(:data) { { 'categories' => [Faker::Lorem.word, Faker::Lorem.word] } }

        it 'transforms languages names into languages codes' do
          expect(subject[:categories]).to eq data['categories']
        end
      end

      context 'when categories is blank' do
        let(:data) { {} }

        it 'returns an empty array' do
          expect(subject[:categories]).to eq []
        end
      end
    end

    describe '#production_credits' do
      let(:publisher_a) { Faker::Lorem.word }
      let(:publisher_b) { Faker::Lorem.word }
      let(:developer_a) { Faker::Lorem.word }
      let(:developer_b) { Faker::Lorem.word }

      let(:data) do
        { 'publishers' => [publisher_a, publisher_b], 'developers' => [developer_a, developer_b] }
      end

      context 'when publishers is present' do
        it 'adds publishers data to production credits' do
          expect(subject[:production_credits]).to include(
            company: publisher_a, role: 'publisher'
          )

          expect(subject[:production_credits]).to include(
            company: publisher_b, role: 'publisher'
          )
        end
      end

      context 'when developers is present' do
        it 'adds developers data to production credits' do
          expect(subject[:production_credits]).to include(
            company: developer_a, role: 'developer'
          )

          expect(subject[:production_credits]).to include(
            company: developer_b, role: 'developer'
          )
        end
      end

      context 'when publishers and developers are blank' do
        let(:data) { {} }

        it 'returns an empty array' do
          expect(subject[:production_credits]).to eq []
        end
      end
    end

    describe '#extra' do
      let(:data) do
        {
          'esrb' => Faker::Lorem.word,
          'generalFilters' => [
            'Demo available', 'DLC available', 'Online Play via Nintendo Switch Online', 'Nintendo Switch Game Voucher'
          ],
          'players' => Faker::Lorem.word,
          'filterShops' => ['At retail']
        }
      end

      it 'adds age_rating trait to hash' do
        expect(subject.dig(:extra, :age_rating)).to eq "ESRB #{data['esrb']}"
      end

      it 'adds demo_available trait to hash' do
        expect(subject.dig(:extra, :demo_available)).to be true
      end

      it 'adds has_addon_content trait to hash' do
        expect(subject.dig(:extra, :has_addon_content)).to be true
      end

      it 'adds num_of_players_text trait to hash' do
        expect(subject.dig(:extra, :num_of_players_text)).to eq data['players']
      end

      it 'adds paid_subscription_required trait to hash' do
        expect(subject.dig(:extra, :paid_subscription_required)).to be true
      end

      it 'adds physical_version trait to hash' do
        expect(subject.dig(:extra, :physical_version)).to be true
      end

      it 'adds voucher_redeemable trait to hash' do
        expect(subject.dig(:extra, :voucher_redeemable)).to be true
      end
    end
  end
end
