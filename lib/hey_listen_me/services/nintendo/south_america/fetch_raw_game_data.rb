module Nintendo
  module SouthAmerica
    class FetchRawGameData < Actor
      input :crawler, type: Nintendo::SouthAmericaGameCrawler, default: -> { Nintendo::SouthAmericaGameCrawler.new }

      output :data_source, type: String
      output :external_id_key, type: String
      output :raw_data, type: Array

      def call
        self.data_source = DataSource::NINTENDO_BRASIL
        self.external_id_key = 'provider_identifier'
        self.raw_data = crawler.crawl(country: :brasil)
      end
    end
  end
end
