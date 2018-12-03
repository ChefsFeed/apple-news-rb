module AppleNews
  class Section
    include Resource
    include Links
    include AppleNews::ArticleCommonMethods

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

    def url_base_part
      'sections'
    end
  end
end
