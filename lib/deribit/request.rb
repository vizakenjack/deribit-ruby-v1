require "base64"
require "net/http"
require "json"

module Deribit
  class Request
    attr_accessor :key, :secret, :base_uri

    def initialize(key, secret, test_server: false)
      @key = key
      @secret = secret
      @base_uri = (ENV["DERIBIT_SERVER"] == "test" || test_server) ? URI(TEST_URL) : URI(SERVER_URL)
    end

    def send(path: DEFAULT_REQUEST_PATH, params: {})
      uri = base_uri + path

      if path.start_with?(PRIVATE_PATH)
        request = Net::HTTP::Post.new(uri.path)
        request.body = URI.encode_www_form(params)
        request.add_field "x-deribit-sig", generate_signature(path, params)

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
      else
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
      end

      if is_error_response?(response)
        puts "Response error: #{response.inspect}" if ENV["DERIBIT_DEBUG"]
        raise Error.new(code: response.code)
      else
        process(response)
      end
    end

    def process(response)
      json = JSON.parse(response.body, symbolize_names: true)

      raise Error.new(key: key, message: json[:message]) unless json[:success]

      if json.include?(:result)
        json[:result]
      elsif json.include?(:message)
        json[:message]
      else
        "ok"
      end
    end

    def generate_signature(path, params = {})
      timestamp = Time.now.utc.to_i + 1000

      signature_data = {
        _: timestamp,
        _ackey: key,
        _acsec: secret,
        _action: path,
      }

      signature_data.update(params)
      sorted_signature_data = signature_data.sort

      converter = ->(data) {
        key = data[0]
        value = data[1]
        if value.is_a?(Array)
          [key.to_s, value.join].join("=")
        else
          [key.to_s, value.to_s].join("=")
        end
      }

      items = sorted_signature_data.map(&converter)
      signature_string = items.join("&")

      sha256 = OpenSSL::Digest::SHA256.new
      sha256_signature = sha256.digest(signature_string.encode("utf-8"))

      base64_signature = Base64.encode64(sha256_signature).encode("utf-8")

      [key, timestamp, base64_signature].join(".").strip
    end

    def is_error_response?(response)
      code = response.code.to_i
      code == 0 || code >= 400
    end
  end
end
