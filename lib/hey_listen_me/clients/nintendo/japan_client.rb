module Nintendo
  class JapanClient
    include HTTParty

    base_uri 'https://search.nintendo.jp/nintendo_soft'
    default_params(
      opt_hard: '1_HAC',
      fq: 'ssitu_s:onsale OR ssitu_s:preorder OR ssitu_s:unreleased',
      sort: 'sodate desc'
    )

    def fetch(page:, per_page: 300)
      result = self.class.get('/search.json', query: { page: page, limit: per_page })
      result.parsed_response
    end
  end
end
