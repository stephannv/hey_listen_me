module Nintendo
  # rubocop:disable Metrics/ClassLength
  class JapanDataAdapter
    CERO_RATINGS = {
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
    }.freeze

    def initialize(data)
      @data = data
    end

    # rubocop:disable Metrics/MethodLength
    def adapt
      {
        platform: platform,
        data_source: data_source,
        item_type: item_type,
        title: title,
        alternative_titles: [],
        short_description: nil,
        long_description: long_description,
        release_date: release_date,
        release_date_text: release_date_text,
        website_url: website_url,
        main_image_url: main_image_url,
        banner_image_url: banner_image_url,
        provider_identifier: provider_identifier,
        provider_identifiers: provider_identifiers,
        related_dlcs: related_dlcs,
        languages: languages,
        categories: categories,
        production_credits: production_credits,
        extra: extra
      }
    end
    # rubocop:enable Metrics/MethodLength

    private

    def platform
      case @data['hard']
      when '1_HAC'
        'nintendo_switch'
      else
        raise "#{@data['hard']} - NOT MAPPED PLATFORM"
      end
    end

    def data_source
      DataSource::NINTENDO_JAPAN
    end

    def item_type
      case @data['sform']
      when 'HAC_DOWNLOADABLE', 'HAC_DL'
        ItemType::GAME
      when 'DLC', 'DL_DLC'
        ItemType::DLC
      else
        raise "#{@data['sform']} - NOT MAPPED ITEM TYPE"
      end
    end

    def title
      @data['title']&.tr('®™', '')
    end

    def long_description
      @data['text']
    end

    def release_date
      @data['dsdate'].nil? ? '' : Date.parse(@data['dsdate'])
    end

    def release_date_text
      @data['sdate']
    end

    def website_url
      case item_type
      when ItemType::GAME
        "https://ec.nintendo.com/JP/ja/titles/#{@data['nsuid']}"
      when ItemType::DLC
        if @data['sctg'].to_s.empty?
          ''
        else
          "https://ec.nintendo.com/JP/ja/#{@data['sctg']}/#{@data['nsuid']}"
        end
      end
    end

    def main_image_url
      "https://img-eshop.cdn.nintendo.net/i/#{@data['iurl']}.jpg?w=560&h=316"
    end

    def banner_image_url
      image_url = @data['sslurl'].to_a.first
      "https://img-eshop.cdn.nintendo.net/i/#{image_url}.jpg?w=560&h=316" if image_url
    end

    def provider_identifier
      @data['nsuid']
    end

    def provider_identifiers
      [
        @data['id'], @data['nsuid']
      ].uniq.compact
    end

    def related_dlcs
      @data['cnsuid']
    end

    def languages
      @data['lang'].to_a.map(&:upcase)
    end

    def categories
      @data['genre'].to_a
    end

    def production_credits
      credits_data = []
      credits_data << { company: @data['maker'], role: 'publisher' } if @data['maker']
      credits_data
    end

    def extra
      {
        age_rating: CERO_RATINGS[@data['cero']],
        has_addon_content: @data['cnsuid'].to_a.any?,
        num_of_players_text: @data['player'],
        paid_subscription_required: @data['nso'].to_a.include?('1'),
        physical_version: @data['sform'] == 'HAC_DOWNLOADABLE'
      }.delete_if { |_, v| v.nil? }
    end
  end
  # rubocop:enable Metrics/ClassLength
end
