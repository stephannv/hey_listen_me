module Nintendo
  module Japan
    class FetchData < Actor
      input :client, type: Nintendo::JapanClient, default: -> { Nintendo::JapanClient.new }

      output :data_source, type: String
      output :external_id_key, type: String
      output :raw_data, type: Array
      output :ignored_keys_for_checksum, type: Array

      def call
        self.data_source = DataSource::NINTENDO_JAPAN
        self.external_id_key = 'id'
        self.ignored_keys_for_checksum = []
        self.raw_data = []

        (1..).each do |page_number|
          data = fetch_page_data(page: page_number)

          break if data.to_a.empty?

          self.raw_data += data
        end
      end

      private

      def fetch_page_data(page:)
        result = client.fetch(page: page)
        result.to_h.dig('result', 'items')
      end
    end
  end
end
