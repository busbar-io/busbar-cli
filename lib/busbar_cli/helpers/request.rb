require 'net/http'

class Request
  class << self
    def get(path)
      request = Net::HTTP::Get.new(uri_for(path))
      execute(request)
    end

    def post(path, body)
      request      = Net::HTTP::Post.new(uri_for(path))
      request.body = body.to_json
      request['Content-Type'] = 'application/json'
      execute(request)
    end

    def put(path, body)
      request      = Net::HTTP::Put.new(uri_for(path))
      request.body = body.to_json
      request['Content-Type'] = 'application/json'
      execute(request)
    end

    def delete(path)
      request = Net::HTTP::Delete.new(uri_for(path))
      execute(request)
    end

    private

    def uri_for(path)
      URI("#{api_url}#{path.sub(/^\\+/, '')}")
    end

    def api_url
      BUSBAR_API_URL
    end

    def execute(request)
      response = nil

      Net::HTTP.start(request.uri.host, request.uri.port) do |http|
        response = http.request(request)
      end

      case response.code
      when '500'
        exit_with_error_warn(request)
      when '503'
        exit_with_503_warn(request)
      when '504'
        exit_with_504_warn(request)
      end

      response
    rescue SocketError
      puts "No connection could be established with the Busbar server (#{api_url}).\n" \
           'You may need to connect to a VPN to access it.'
      exit 0
    end

    def exit_with_error_warn(request)
      puts "Internal error on Busbar server (#{api_url}).\n" \
           "URI: #{request.uri}\n" \
           "Body: #{request.body}\n" \
           'Response code: 500'

      exit 0
    end

    def exit_with_503_warn(request)
      puts "(#{api_url}) service is unavailable.\n" \
            "URI: #{request.uri}\n" \
            'Response code: 503'
      exit 0
    end

    def exit_with_504_warn(request)
      puts "(#{api_url}) gateway Time-out.\n" \
            "URI: #{request.uri}\n" \
            'Response code: 504'
      exit 0
    end
  end
end
