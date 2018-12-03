module AppleNews
  class Section
    include Resource
    include Links

    attr_reader :id, :type, :name, :is_default, :links, :created_at, :modified_at, :share_url

    def initialize(id, data = nil, config = AppleNews.config)
      @id = id
      @config = config
      @resource_path = '/sections'

      data.nil? ? hydrate! : set_read_only_properties(data)
    end

    def channel
      Channel.new(channel_link_id('channel'), nil, config)
    end

    #FIXME: factor out and reuse for Channel
    def articles(params = {})
      params  = params.with_indifferent_access
      hydrate = params.delete(:hydrate)
      include_meta = params.delete(:include_meta)

      resp = get_request("/sections/#{id}/articles", params)

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

    #FIXME: factor out and reuse for Channel
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
