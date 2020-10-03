module Nintendo
  class EuropeClient
    include HTTParty

    base_uri 'https://searching.nintendo-europe.com/en'
    default_params q: '*', sort: 'date_from desc', fq: 'originally_for_t:HAC'

    def fetch(page:, per_page: 1000)
      query_params = pagination_params(page: page, per_page: per_page)
      result = self.class.get('/select', query: query_params)
      result.parsed_response
    end

    private

    def pagination_params(page:, per_page:)
      {
        start: per_page * (page - 1),
        rows: per_page
      }
    end
  end
end
