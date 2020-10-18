module Nintendo
  class NorthAmericaDataAdapter
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
        banner_image_url: nil,
        provider_identifier: provider_identifier,
        provider_identifiers: provider_identifiers,
        languages: [],
        categories: categories,
        production_credits: production_credits,
        extra: extra
      }
    end
    # rubocop:enable Metrics/MethodLength

    private

    def platform
      case @data['platform']
      when 'Nintendo Switch'
        'nintendo_switch'
      else
        raise "#{@data['platform']} - NOT MAPPED PLATFORM"
      end
    end

    def data_source
      DataSource::NINTENDO_NORTH_AMERICA
    end

    def item_type
      ItemType::GAME
    end

    def title
      @data['title']&.tr('®™', '')
    end

    def long_description
      @data['description']
    end

    def release_date
      Date.parse(@data['releaseDateDisplay'])
    rescue StandardError
      Date.parse('31/12/2049')
    end

    def release_date_text
      Date.parse(@data['releaseDateDisplay']).to_s
    rescue StandardError
      @data['releaseDateDisplay']
    end

    def website_url
      "https://www.nintendo.com#{@data['url']}"
    end

    def main_image_url
      "https://www.nintendo.com#{@data['boxart']}"
    end

    def provider_identifier
      @data['nsuid']
    end

    def provider_identifiers
      [@data['nsuid'], @data['objectID']].flatten.compact
    end

    def categories
      @data['categories'].to_a
    end

    def production_credits
      credits_data = []

      @data['publishers'].to_a.compact.each do |publisher|
        credits_data << { company: publisher, role: 'publisher' }
      end

      @data['developers'].to_a.compact.each do |developer|
        credits_data << { company: developer, role: 'developer' }
      end

      credits_data
    end

    # rubocop:disable Metrics/AbcSize
    def extra
      {
        age_rating: "ESRB #{@data['esrb']}",
        demo_available: @data['generalFilters'].to_a.include?('Demo available'),
        has_addon_content: @data['generalFilters'].to_a.include?('DLC available'),
        num_of_players_text: @data['players'],
        paid_subscription_required: @data['generalFilters'].to_a.include?('Online Play via Nintendo Switch Online'),
        physical_version: @data['filterShops'].to_a.include?('At retail'),
        voucher_redeemable: @data['generalFilters'].to_a.include?('Nintendo Switch Game Voucher')
      }.delete_if { |_, v| v.nil? }
    end
    # rubocop:enable Metrics/AbcSize
  end
end
