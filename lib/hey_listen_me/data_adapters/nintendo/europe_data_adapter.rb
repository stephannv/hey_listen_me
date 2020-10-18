module Nintendo
  # rubocop:disable Metrics/ClassLength
  class EuropeDataAdapter
    def initialize(data)
      @data = data
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def adapt
      {
        platform: platform,
        data_source: data_source,
        item_type: item_type,
        title: title,
        alternative_titles: alternative_titles,
        short_description: short_description,
        long_description: long_description,
        release_date: release_date,
        release_date_text: release_date_text,
        website_url: website_url,
        main_image_url: main_image_url,
        banner_image_url: banner_image_url,
        provider_identifier: provider_identifier,
        provider_identifiers: provider_identifiers,
        series: series,
        related_game: related_game,
        languages: languages,
        categories: categories,
        production_credits: production_credits,
        extra: extra
      }
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def platform
      case @data['originally_for_t']
      when 'HAC'
        'nintendo_switch'
      else
        raise "#{@data['originally_for_t']} - NOT MAPPED PLATFORM"
      end
    end

    def data_source
      DataSource::NINTENDO_EUROPE
    end

    def item_type
      case @data['type']
      when 'GAME'
        ItemType::GAME
      when 'DLC'
        ItemType::DLC
      else
        raise "#{@data['type']} - NOT MAPPED ITEM TYPE"
      end
    end

    def title
      @data['title']&.tr('®™', '')
    end

    def alternative_titles
      @data['title_extras_txt']
    end

    def short_description
      @data['excerpt']
    end

    def long_description
      @data['gift_finder_description_s']
    end

    def release_date
      Date.parse(@data['date_from'] || '2049-12-31')
    end

    def release_date_text
      @data['pretty_date_s'] || 'TBA'
    end

    def website_url
      "https://www.nintendo.co.uk#{@data['url']}"
    end

    def main_image_url
      "https:#{@data['image_url']}"
    end

    def banner_image_url
      url = @data['image_url_h2x1_s']
      "https:#{url}" if url
    end

    def provider_identifier
      @data['nsuid_txt']&.first
    end

    def provider_identifiers
      [@data['fs_id'], @data['product_code_text'], @data['nsuid_txt']].flatten.compact
    end

    def series
      @data['game_series_txt']&.first&.titleize
    end

    def related_game
      @data['related_game_id_s']
    end

    def languages
      langs = @data['language_availability']&.first&.split(',')
      langs.to_a.map { |lang| I18nData.language_code(lang.capitalize) }
    end

    def categories
      @data['pretty_game_categories_txt'].to_a
    end

    def production_credits
      credits_data = []
      credits_data << { company: @data['publisher'], role: 'publisher' } if @data['publisher']
      credits_data << { company: @data['developer'], role: 'developer' } if @data['developer']
      credits_data
    end

    # rubocop:disable Metrics/MethodLength
    def extra
      {
        age_rating: age_rating,
        cloud_save: @data['cloud_saves_b'],
        copyright: @data['copyright_s'],
        compatible_with_labo: @data['labo_b'],
        has_addon_content: @data['add_on_content_b'],
        hd_rumble: @data['hd_rumble_b'],
        max_num_of_players: @data['players_to'],
        mii_support: @data['mii_support'],
        min_num_of_players: @data['players_from'],
        paid_subscription_required: @data['paid_subscription_required_b'],
        physical_version: @data['physical_version_b'],
        uses_nfc_feature: @data['near_field_comm_b'],
        voice_chat: @data['voice_chat_b']
      }.delete_if { |_, v| v.nil? }
    end
    # rubocop:enable Metrics/MethodLength

    def age_rating
      rating = "#{@data['age_rating_type']} #{@data['age_rating_value']}".upcase
      rating.strip.empty? ? nil : rating
    end
  end
  # rubocop:enable Metrics/ClassLength
end
