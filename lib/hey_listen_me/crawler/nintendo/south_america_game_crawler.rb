module Nintendo
  class SouthAmericaGameCrawler
    SOUTH_AMERICA_STORE_URLS = {
      brasil: 'https://store.nintendo.com.br'
    }.freeze

    def crawl(country: :brasil)
      page = fetch_page(country: country)

      crawl_data(page: page)
    end

    private

    def fetch_page(country:)
      Nokogiri::HTML(Down.download(SOUTH_AMERICA_STORE_URLS[country]))
    end

    # rubocop:disable Metrics/MethodLength
    def crawl_data(page:)
      page.css('div.category-product-item').map do |el|
        {
          'platform' => 'nintendo_switch',
          'data_source' => DataSource::NINTENDO_BRASIL,
          'item_type' => ItemType::GAME,
          'provider_identifier' => crawl_provider_identifier(el),
          'title' => crawl_title(el),
          'release_date' => crawl_release_date(el).nil? ? '' : Date.parse(crawl_release_date(el)).to_s,
          'release_date_text' => crawl_release_date(el),
          'main_image_url' => crawl_main_image_url(el),
          'website_url' => crawl_website_url(el),
          'extra' => {
            'is_dlc_available' => crawl_dlc_availability(el),
            'is_demo_available' => crawl_demo_availability(el)
          }
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    def crawl_provider_identifier(element)
      element.css('div.category-product-item-title div.price-box').first[:'data-product-id']
    end

    def crawl_title(element)
      element.css('div.category-product-item-title a').first.content.strip
    end

    def crawl_website_url(element)
      element.css('div.category-product-item-title a').first[:href]
    end

    def crawl_main_image_url(element)
      element.css('div.category-product-item-img a.photo span span img').first[:src]
    end

    def crawl_release_date(element)
      element.css('div.category-product-item-released').first.content.strip[-10..]
    end

    def crawl_dlc_availability(element)
      element.css('.category-product-item-img .category-product-item-labels .label.dlc').to_a.any?
    end

    def crawl_demo_availability(element)
      element.css('.category-product-item-img .category-product-item-labels .label.download-code').to_a.any?
    end
  end
end
