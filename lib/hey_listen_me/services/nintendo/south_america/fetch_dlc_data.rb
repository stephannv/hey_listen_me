module Nintendo
  module SouthAmerica
    class FetchDlcData < Actor
      input :crawler, type: Nintendo::SouthAmericaDlcCrawler, default: -> { Nintendo::SouthAmericaDlcCrawler.new }
      input :raw_info_repository, type: ::RawInfoRepository, default: -> { ::RawInfoRepository.new }

      output :data_source, type: String
      output :external_id_key, type: String
      output :raw_data, type: Array

      def call
        self.data_source = DataSource::NINTENDO_BRASIL
        self.external_id_key = 'identifier'
        self.raw_data = crawl_dlcs_data.flatten
      end

      private

      def crawl_dlcs_data
        games_with_dlc_from_south_america.map do |raw_info_data|
          craw_dlc_data(raw_info: RawInfo.new(raw_info_data))
        end
      end

      def craw_dlc_data(raw_info:)
        crawler.crawl(website_url: raw_info.data['website_url']).map do |dlc_data|
          dlc_data.merge(extra_data_for_dlc(raw_info: raw_info))
        end
      end

      def games_with_dlc_from_south_america
        raw_info_repository.games_with_dlc_from_south_america(data_source: DataSource::NINTENDO_BRASIL)
      end

      def extra_data_for_dlc(raw_info:)
        {
          'website_url' => raw_info.data['website_url'],
          'game_title' => raw_info.data['title'],
          'game_identifier' => raw_info.data['identifier'],
          'image_url' => raw_info.data['image_url']
        }
      end
    end
  end
end
