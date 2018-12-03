module AppleNews
  module Request
    class Get
      attr_reader :uri

      def initialize(url, params, config = AppleNews.config)
        @config = config
        @params = params

        @uri = URI::parse(File.join(@config.api_base, url))
        @uri.query = URI.encode_www_form(params) if params.any?
      end

      def call
        http = Net::HTTP.new(@uri.hostname, @uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        res = http.get(@uri, headers)
        JSON.parse(res.body)
      end

      private

      def headers
        security = AppleNews::Security.new('GET', @uri.to_s, @config)
        { 'Authorization' => security.authorization }
      end
    end
  end
end
