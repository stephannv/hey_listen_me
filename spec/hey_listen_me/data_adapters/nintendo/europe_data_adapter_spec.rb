RSpec.describe Nintendo::EuropeDataAdapter, type: :data_adapter do
  describe 'Adapted fields' do
    subject { described_class.new(base_data.merge(data)).adapt }

    let(:data) { {} }
    let(:base_data) { { 'originally_for_t' => 'HAC', 'type' => 'GAME' } }

    describe '#platform' do
      context 'when originally_for_t is HAC' do
        let(:data) { { 'originally_for_t' => 'HAC' } }

        it 'return NSW' do
          expect(subject[:platform]).to eq 'nintendo_switch'
        end
      end

      context 'when originally_for_t isn`t mapped' do
        let(:data) { { 'originally_for_t' => Faker::Lorem.word } }

        it 'raises error' do
          expect { subject }.to raise_error("#{data['originally_for_t']} - NOT MAPPED PLATFORM")
        end
      end
    end

    describe '#data_source' do
      it 'returns `nintendo_europe`' do
        expect(subject[:data_source]).to eq DataSource::NINTENDO_EUROPE
      end
    end

    describe '#item_type' do
      context 'when type is GAME' do
        let(:data) { { 'type' => 'GAME' } }

        it 'returns ItemType::GAME' do
          expect(subject[:item_type]).to eq ItemType::GAME
        end
      end

      context 'when type is DLC' do
        let(:data) { { 'type' => 'DLC' } }

        it 'returns ItemType::DLC' do
          expect(subject[:item_type]).to eq ItemType::DLC
        end
      end

      context 'when type isn`t mapped' do
        let(:data) { { 'type' => Faker::Lorem.word } }

        it 'raises error' do
          expect { subject }.to raise_error("#{data['type']} - NOT MAPPED ITEM TYPE")
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

    describe '#alternative_titles' do
      let(:data) { { 'title_extras_txt' => [Faker::Lorem.word] } }

      it 'returns title_extras_txt content' do
        expect(subject[:alternative_titles]).to eq data['title_extras_txt']
      end
    end

    describe '#short_description' do
      let(:data) { { 'excerpt' => Faker::Lorem.word } }

      it 'returns excerpt content' do
        expect(subject[:short_description]).to eq data['excerpt']
      end
    end

    describe '#long_description' do
      let(:data) { { 'gift_finder_description_s' => Faker::Lorem.word } }

      it 'returns gift_finder_description_s content' do
        expect(subject[:long_description]).to eq data['gift_finder_description_s']
      end
    end

    describe '#release_date' do
      context 'when date_from is present' do
        let(:data) { { 'date_from' => '2020-01-01' } }

        it 'returns date_from parsed to date' do
          expect(subject[:release_date]).to eq Date.parse('2020-01-01')
        end
      end

      context 'when date_from is blank' do
        let(:data) { {} }

        it 'returns 31/12/2049 date' do
          expect(subject[:release_date]).to eq Date.parse('2049-12-31')
        end
      end
    end

    describe '#release_date_text' do
      context 'when pretty_date_s is present' do
        let(:data) { { 'pretty_date_s' => Faker::Lorem.word } }

        it 'returns pretty_date_s text' do
          expect(subject[:release_date_text]).to eq data['pretty_date_s']
        end
      end

      context 'when pretty_date_s is blank' do
        let(:data) { {} }

        it 'returns TBA text' do
          expect(subject[:release_date_text]).to eq 'TBA'
        end
      end
    end

    describe '#website_url' do
      let(:data) { { 'url' => Faker::Lorem.word } }

      it 'adds nintendo uk domain as prefix to url' do
        expect(subject[:website_url]).to eq "https://www.nintendo.co.uk#{data['url']}"
      end
    end

    describe '#main_image_url' do
      let(:data) { { 'image_url' => Faker::Lorem.word } }

      it 'adds https protocol to image_url' do
        expect(subject[:main_image_url]).to eq "https:#{data['image_url']}"
      end
    end

    describe '#banner_image_url' do
      context 'when image_url_h2x1_s is present' do
        let(:data) { { 'image_url_h2x1_s' => Faker::Lorem.word } }

        it 'adds https protocol to image_url_h2x1_s' do
          expect(subject[:banner_image_url]).to eq "https:#{data['image_url_h2x1_s']}"
        end
      end

      context 'when image_url_h2x1_s is blank' do
        let(:data) { {} }

        it 'returns nil' do
          expect(subject[:banner_image_url]).to be_nil
        end
      end
    end

    describe '#provider_identifier' do
      context 'when nsuid_txt array has content' do
        let(:provider_identifier) { Faker::Lorem.word }
        let(:data) { { 'nsuid_txt' => [provider_identifier] } }

        it 'returns first element' do
          expect(subject[:provider_identifier]).to eq provider_identifier
        end
      end

      context 'when nsuid_txt array is empty' do
        let(:data) { {} }

        it 'returns nil' do
          expect(subject[:provider_identifier]).to be_nil
        end
      end
    end

    describe '#provider_identifiers' do
      let(:fs_id) { Faker::Lorem.word }
      let(:product_code_text) { Faker::Lorem.word }
      let(:nsuid_txt) { [Faker::Lorem.word, nil] }
      let(:data) { { 'fs_id' => fs_id, 'product_code_text' => product_code_text, 'nsuid_txt' => nsuid_txt } }

      it 'returns fs_id, product_code_text and nsuid_txt flattened and compacted' do
        expect(subject[:provider_identifiers]).to eq [fs_id, product_code_text, nsuid_txt].flatten.compact
      end
    end

    describe '#series' do
      context 'when game_series_txt array has content' do
        let(:data) { { 'game_series_txt' => ['a-b-c'] } }

        it 'returns first text titleized' do
          expect(subject[:series]).to eq 'A B C'
        end
      end

      context 'when game_series_txt array is empty' do
        let(:data) { { 'game_series_txt' => [] } }

        it 'returns nil' do
          expect(subject[:series]).to be_nil
        end
      end

      context 'when game_series_txt array is nill' do
        let(:data) { {} }

        it 'returns nil' do
          expect(subject[:series]).to be_nil
        end
      end
    end

    describe '#related_game' do
      let(:data) { { 'related_game_id_s' => Faker::Lorem.word } }

      it 'returns related_game_id_s' do
        expect(subject[:related_game]).to eq data['related_game_id_s']
      end
    end

    describe '#languages' do
      context 'when language_availability is present' do
        let(:data) { { 'language_availability' => ['portuguese,english'] } }

        it 'transforms languages names into languages codes' do
          expect(subject[:languages]).to eq %w[PT EN]
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
      context 'when pretty_game_categories_txt is present' do
        let(:data) { { 'pretty_game_categories_txt' => [Faker::Lorem.word, Faker::Lorem.word] } }

        it 'transforms languages names into languages codes' do
          expect(subject[:categories]).to eq data['pretty_game_categories_txt']
        end
      end

      context 'when pretty_game_categories_txt is blank' do
        let(:data) { {} }

        it 'returns an empty array' do
          expect(subject[:categories]).to eq []
        end
      end
    end

    describe '#production_credits' do
      let(:data) { { 'publisher' => Faker::Lorem.word, 'developer' => Faker::Lorem.word } }

      context 'when publisher is present' do
        it 'adds publisher data to production credits' do
          expect(subject[:production_credits]).to include(
            company: data['publisher'], role: 'publisher'
          )
        end
      end

      context 'when developer is present' do
        it 'adds developer data to production credits' do
          expect(subject[:production_credits]).to include(
            company: data['developer'], role: 'developer'
          )
        end
      end

      context 'when publisher and developer are blank' do
        let(:data) { {} }

        it 'returns an empty array' do
          expect(subject[:production_credits]).to eq []
        end
      end
    end

    describe '#extra' do
      let(:data) do
        {
          'age_rating_type' => Faker::Lorem.word,
          'age_rating_value' => Faker::Lorem.word,
          'cloud_saves_b' => Faker::Lorem.word,
          'copyright_s' => Faker::Lorem.word,
          'labo_b' => Faker::Lorem.word,
          'digital_version_b' => Faker::Lorem.word,
          'switch_game_voucher_b' => Faker::Lorem.word,
          'play_mode_handheld_b' => Faker::Lorem.word,
          'add_on_content_b' => Faker::Lorem.word,
          'hd_rumble_b' => Faker::Lorem.word,
          'players_to' => Faker::Lorem.word,
          'mii_support' => Faker::Lorem.word,
          'players_from' => Faker::Lorem.word,
          'paid_subscription_required_b' => Faker::Lorem.word,
          'physical_version_b' => Faker::Lorem.word,
          'play_mode_tabletop_b' => Faker::Lorem.word,
          'play_mode_tv_b' => Faker::Lorem.word,
          'near_field_comm_b' => Faker::Lorem.word,
          'voice_chat_b' => Faker::Lorem.word
        }
      end

      it 'adds age_rating trait to hash' do
        expect(subject.dig(:extra, :age_rating)).to eq "#{data['age_rating_type']} #{data['age_rating_value']}".upcase
      end

      it 'adds cloud_save trait to hash' do
        expect(subject.dig(:extra, :cloud_save)).to eq data['cloud_saves_b']
      end

      it 'adds copyright trait to hash' do
        expect(subject.dig(:extra, :copyright)).to eq data['copyright_s']
      end

      it 'adds compatible_with_labo trait to hash' do
        expect(subject.dig(:extra, :compatible_with_labo)).to eq data['labo_b']
      end

      it 'adds has_addon_content trait to hash' do
        expect(subject.dig(:extra, :has_addon_content)).to eq data['add_on_content_b']
      end

      it 'adds hd_rumble trait to hash' do
        expect(subject.dig(:extra, :hd_rumble)).to eq data['hd_rumble_b']
      end

      it 'adds max_num_of_players trait to hash' do
        expect(subject.dig(:extra, :max_num_of_players)).to eq data['players_to']
      end

      it 'adds mii_support trait to hash' do
        expect(subject.dig(:extra, :mii_support)).to eq data['mii_support']
      end

      it 'adds min_num_of_players trait to hash' do
        expect(subject.dig(:extra, :min_num_of_players)).to eq data['players_from']
      end

      it 'adds paid_subscription_required trait to hash' do
        expect(subject.dig(:extra, :paid_subscription_required)).to eq data['paid_subscription_required_b']
      end

      it 'adds physical_version trait to hash' do
        expect(subject.dig(:extra, :physical_version)).to eq data['physical_version_b']
      end

      it 'adds uses_nfc_feature trait to hash' do
        expect(subject.dig(:extra, :uses_nfc_feature)).to eq data['near_field_comm_b']
      end

      it 'adds voice_chat trait to hash' do
        expect(subject.dig(:extra, :voice_chat)).to eq data['voice_chat_b']
      end

      context 'when some property is blank' do
        let(:data) { {} }

        it 'rejects property' do
          expect(subject[:extra]).to eq({})
        end
      end
    end
  end
end
