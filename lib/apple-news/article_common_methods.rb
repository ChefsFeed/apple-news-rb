module AppleNews
  module ArticleCommonMethods
    def articles(params = {})
      params  = params.with_indifferent_access
      hydrate = params.delete(:hydrate)
      include_meta = params.delete(:include_meta)

      resp = get_request("/#{url_base_part}/#{id}/articles", params)

      article_array = resp['data'].map do |article|
        data = hydrate == false ? article : {}
        Article.new(article['id'], data, config)
      end

      if include_meta
        meta = resp['meta'] || {}
        [ article_array, meta ]
      else
        article_array
      end
    end

    def all_articles(params = {})
      pages = []
      params_copy = params.dup.merge(
        include_meta: true,
        pageSize: 100,
      )

      while true
        page, meta = articles(params_copy)

        pages << page

        next_page_token = meta['nextPageToken']
        break if next_page_token.blank?

        params_copy.merge! pageToken: next_page_token
      end

      pages.flatten
    end
  end
end
