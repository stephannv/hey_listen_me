RSpec.describe Nintendo::JapanDataAdapter, type: :data_adapter do
  describe 'Constants' do
    it 'has CERO_RATINGS' do
      expect(described_class::CERO_RATINGS).to eq(
        nil => nil,
        '0' => nil,
        '1' => 'CERO A',
        '2' => 'CERO B',
        '3' => 'CERO C',
        '4' => 'CERO D',
        '5' => 'CERO Z',
        '6' => 'CERO Educational/Database',
        '7' => 'CERO Rating Scheduled',
        '8' => 'CERO Regulations-Compatible'
      )
    end
  end

  describe 'Adapted fields' do
    subject { described_class.new(base_data.merge(data)).adapt }

    let(:data) { {} }
    let(:base_data) { { 'hard' => '1_HAC', 'sform' => 'HAC_DL', 'sctg' => Faker::Lorem.word } }

    describe '#platform' do
      context 'when hard is 1_HAC' do
        let(:data) { { 'hard' => '1_HAC' } }

        it 'return NSW' do
          expect(subject[:platform]).to eq 'nintendo_switch'
        end
      end

      context 'when hard isn`t mapped' do
        let(:data) { { 'hard' => Faker::Lorem.word } }

        it 'raises error' do
          expect { subject }.to raise_error("#{data['hard']} - NOT MAPPED PLATFORM")
        end
      end
    end

    describe '#data_source' do
      it 'returns `europe`' do
        expect(subject[:data_source]).to eq DataSource::NINTENDO_JAPAN
      end
    end

    describe '#item_type' do
      context 'when sform is HAC_DOWNLOADABLE' do
        let(:data) { { 'sform' => 'HAC_DOWNLOADABLE' } }

        it 'returns ItemType::GAME' do
          expect(subject[:item_type]).to eq ItemType::GAME
        end
      end

      context 'when sform is HAC_DL' do
        let(:data) { { 'sform' => 'HAC_DL' } }

        it 'returns ItemType::GAME' do
          expect(subject[:item_type]).to eq ItemType::GAME
        end
      end

      context 'when sform is DLC' do
        let(:data) { { 'sform' => 'DLC' } }

        it 'returns ItemType::DLC' do
          expect(subject[:item_type]).to eq ItemType::DLC
        end
      end

      context 'when sform is DL_DLC' do
        let(:data) { { 'sform' => 'DL_DLC' } }

        it 'returns ItemType::DLC' do
          expect(subject[:item_type]).to eq ItemType::DLC
        end
      end

      context 'when type isn`t mapped' do
        let(:data) { { 'sform' => Faker::Lorem.word } }

        it 'raises error' do
          expect { subject }.to raise_error("#{data['sform']} - NOT MAPPED ITEM TYPE")
        end
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
      let(:data) { { 'text' => Faker::Lorem.word } }

      it 'returns text content' do
        expect(subject[:long_description]).to eq data['text']
      end
    end

    describe '#release_date' do
      let(:data) { { 'dsdate' => '2020-01-01' } }

      it 'returns dsdate parsed to date' do
        expect(subject[:release_date]).to eq Date.parse('2020-01-01')
      end
    end

    describe '#release_date_text' do
      let(:data) { { 'sdate' => Faker::Lorem.word } }

      it 'returns sdate text' do
        expect(subject[:release_date_text]).to eq data['sdate']
      end
    end

    describe '#website_url' do
      context 'when type is game' do
        let(:data) { { 'nsuid' => Faker::Lorem.word, 'sform' => 'HAC_DL' } }

        it 'returns ec.nintendo website using nsuid' do
          expect(subject[:website_url]).to eq "https://ec.nintendo.com/JP/ja/titles/#{data['nsuid']}"
        end
      end

      context 'when type is DLC' do
        context 'when sctg is present' do
          let(:data) { { 'nsuid' => Faker::Lorem.word, 'sform' => 'DLC', 'sctg' => Faker::Lorem.word } }

          it 'returns ec.nintendo website using sctg and nsuid' do
            expect(subject[:website_url]).to eq "https://ec.nintendo.com/JP/ja/#{data['sctg']}/#{data['nsuid']}"
          end
        end

        context 'when sctg is blank' do
          let(:data) { { 'id' => Faker::Lorem.word, 'nsuid' => Faker::Lorem.word, 'sform' => 'DLC', 'sctg' => nil } }

          it 'returns empty string' do
            expect(subject[:website_url]).to eq ''
          end
        end
      end
    end

    describe '#main_image_url' do
      let(:data) { { 'iurl' => Faker::Lorem.word } }

      it 'builds image url with iurl' do
        expect(subject[:main_image_url]).to eq "https://img-eshop.cdn.nintendo.net/i/#{data['iurl']}.jpg?w=560&h=316"
      end
    end

    describe '#banner_image_url' do
      context 'when sslurl has content' do
        let(:data) { { 'sslurl' => [Faker::Lorem.word] } }

        it 'adds https protocol to image_url_h2x1_s' do
          image_url = "https://img-eshop.cdn.nintendo.net/i/#{data['sslurl'].first}.jpg?w=560&h=316"
          expect(subject[:banner_image_url]).to eq image_url
        end
      end

      context 'when sslurl is empty' do
        let(:data) { {} }

        it 'returns nil' do
          expect(subject[:banner_image_url]).to be_nil
        end
      end
    end

    describe '#provider_identifier' do
      let(:data) { { 'nsuid' => Faker::Lorem.word } }

      it 'returns nsuid text' do
        expect(subject[:provider_identifier]).to eq data['nsuid']
      end
    end

    describe '#provider_identifiers' do
      let(:id) { Faker::Lorem.word }
      let(:nsuid) { Faker::Lorem.word }
      let(:data) { { 'id' => id, 'nsuid' => nsuid } }

      it 'returns id and nsuid compacted' do
        expect(subject[:provider_identifiers]).to eq [id, nsuid].uniq.compact
      end
    end

    describe '#related_dlcs' do
      let(:data) { { 'cnsuid' => [Faker::Lorem.word, Faker::Lorem.word] } }

      it 'returns cnsuid' do
        expect(subject[:related_dlcs]).to eq data['cnsuid']
      end
    end

    describe '#languages' do
      context 'when lang is present' do
        let(:data) { { 'lang' => [Faker::Lorem.word, Faker::Lorem.word] } }

        it 'returns upcased langs' do
          expect(subject[:languages]).to eq data['lang'].map(&:upcase)
        end
      end

      context 'when language_availability is blank' do
        let(:data) { {} }

        it 'returns an empty array' do
          expect(subject[:languages]).to eq []
        end
      end
    end

    describe '#categories' do
      context 'when genre is present' do
        let(:data) { { 'genre' => [Faker::Lorem.word, Faker::Lorem.word] } }

        it 'transforms languages names into languages codes' do
          expect(subject[:categories]).to eq data['genre']
        end
      end

      context 'when genre is blank' do
        let(:data) { {} }

        it 'returns an empty array' do
          expect(subject[:categories]).to eq []
        end
      end
    end

    describe '#production_credits' do
      let(:data) { { 'maker' => Faker::Lorem.word } }

      context 'when maker is present' do
        it 'adds publisher data to production credits' do
          expect(subject[:production_credits]).to include(
            company: data['maker'], role: 'publisher'
          )
        end
      end

      context 'when maker is blank' do
        let(:data) { {} }

        it 'returns an empty array' do
          expect(subject[:production_credits]).to eq []
        end
      end
    end

    describe '#extra' do
      let(:data) do
        {
          'cero' => [('0'..'8').to_a.sample],
          'cnsuid' => [Faker::Lorem.word],
          'player' => Faker::Lorem.word,
          'nso' => ['1'],
          'sform' => 'HAC_DOWNLOADABLE'
        }
      end

      it 'adds age_rating trait to hash' do
        expect(subject.dig(:extra, :age_rating)).to eq described_class::CERO_RATINGS[data['cero']]
      end

      it 'adds has_addon_content trait to hash' do
        expect(subject.dig(:extra, :has_addon_content)).to be true
      end

      it 'adds num_of_players_text trait to hash' do
        expect(subject.dig(:extra, :num_of_players_text)).to eq data['player']
      end

      it 'adds paid_subscription_required trait to hash' do
        expect(subject.dig(:extra, :paid_subscription_required)).to be true
      end

      it 'adds physical_version trait to hash' do
        expect(subject.dig(:extra, :physical_version)).to eq true
      end
    end
  end
end
