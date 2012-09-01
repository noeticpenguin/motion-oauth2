module Motion
  class OAuth2
    attr_accessor :access_token, :schema

    def initialize(access_token, schema = :Bearer)
      self.access_token = access_token
      self.schema = schema
    end

    def get(url, options = {}, &block)
      request :get, url, options, &block
    end

    def post(url, options = {}, &block)
      request :post, url, options, &block
    end

    def put(url, options = {}, &block)
      request :put, url, options, &block
    end

    def delete(url, options = {}, &block)
      request :delete, url, options, &block
    end

    def head(url, options = {}, &block)
      request :head, url, options, &block
    end

    def patch(url, options = {}, &block)
      request :patch, url, options, &block
    end

    def self.authenticate_client(url, client_id, client_secret, options = {}, &block)
      BubbleWrap::HTTP.post(url, with_client_credentials(client_id, client_secret, options)) do |raw_response|
        response = Response.new raw_response
        block.call(response) if block
      end
    end

    private

    def self.with_client_credentials(client_id, client_secret, options = {})
      options[:payload] ||= {}
      options[:payload].merge!(
        grant_type: 'client_credentials',
        client_id: client_id,
        client_secret: client_secret
      )
      options.merge!(
        grant_type: 'client_credentials',
        client_id: client_id,
        client_secret: client_secret
      )
    end

    def request(method, url, options = {}, &block)
      BubbleWrap::HTTP.send method, url, with_token(options) do |raw_response|
        response = Response.new raw_response
        if block.is_a? Proc
          block.call response
        else
          # TODO:
          #  Warn here that developers should handle OAuth2 error here.
          #  But how to *warn* using NSLog??
          NSLog "You don't care about OAuth2 errors? otherwise specify your own callback as block."
        end
      end
    end

    def with_token(options = {})
      options[:headers] ||= {}
      options[:headers].merge!(
        Authorization: "#{schema} #{access_token}"
      )
      options
    end
  end
end
