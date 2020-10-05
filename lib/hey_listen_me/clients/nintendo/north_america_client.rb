module Nintendo
  class NorthAmericaClient
    APPLICATION_ID = ENV['NINTENDO_NORTH_AMERICA_APPLICATION_ID']
    API_KEY = ENV['NINTENDO_NORTH_AMERICA_API_KEY']

    def initialize(client: Algolia::Client.new(application_id: APPLICATION_ID, api_key: API_KEY))
      @client = client
    end

    def fetch(index:, query:)
      response = index.search(query, queryType: 'prefixAll', hitsPerPage: 1000, filters: 'platform:"Nintendo Switch"')
      response['hits'].to_a
    end

    def index_asc
      @index_asc ||= @client.init_index('noa_aem_game_en_us_title_asc')
    end

    def index_desc
      @index_desc ||= @client.init_index('noa_aem_game_en_us_title_des')
    end
  end
end
