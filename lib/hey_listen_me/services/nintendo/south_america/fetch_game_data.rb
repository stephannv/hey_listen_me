module Nintendo
  module SouthAmerica
    class FetchGameData < Actor
      input :crawler, type: Nintendo::SouthAmericaGameCrawler, default: -> { Nintendo::SouthAmericaGameCrawler.new }

      output :data_source, type: String
      output :external_id_key, type: String
      output :raw_data, type: Array
      output :ignored_keys_for_checksum, type: Array

      def call
        self.data_source = DataSource::NINTENDO_BRASIL
        self.external_id_key = 'identifier'
        self.ignored_keys_for_checksum = []
        self.raw_data = crawler.crawl(country: :brasil)
      end
    end
  end
end
