module Nintendo
  module NorthAmerica
    class FetchRawData < Actor
      input :client, type: Nintendo::NorthAmericaClient, default: -> { Nintendo::NorthAmericaClient.new }

      output :data_source, type: String
      output :external_id_key, type: String
      output :raw_data, type: Array

      def call
        self.data_source = DataSource::NINTENDO_NORTH_AMERICA
        self.external_id_key = 'objectID'

        all_data = queries.map do |query|
          fetch_data(query: query)
        end

        self.raw_data = all_data.flatten.uniq { |d| d['objectID'] }.map { |d| d.except('_highlightResult') }
      end

      private

      def queries
        ('a'..'z').to_a + ('0'..'9').to_a
      end

      def fetch_data(query:)
        data = client.fetch(index: client.index_asc, query: query)
        data += client.fetch(index: client.index_desc, query: query) if data.size >= 1000
        data
      end
    end
  end
end
