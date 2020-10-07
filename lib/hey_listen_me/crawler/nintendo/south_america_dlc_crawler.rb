class Nintendo::SouthAmericaDlcCrawler
  def crawl(website_url:)
    page = fetch_page(website_url)

    crawl_data(page: page)
  end

  private def fetch_page(website_url)
    Nokogiri::HTML(Down.download(website_url))
  end

  # rubocop:disable Metrics/MethodLength
  private def crawl_data(page:)
    page.css('.product-options-item').map do |el|
      {
        'item_type' => 'dlc',
        'identifier' => crawl_identifier(el),
        'title' => crawl_title(el)
      }
    end
  end
  # rubocop:enable Metrics/MethodLength

  private def crawl_identifier(element)
    element.css('.product-options-item-price .price-box').first['data-product-id'.to_sym]
  end

  private def crawl_title(element)
    element.css('.product-options-item-title a').first.content.strip
  end
end
