require 'base64'
require 'httparty'

module Deribit
  class Request
    include HTTParty
    # debug_output $stdout

    base_uri ENV['DOMAIN'] || 'https://www.deribit.com/'

    attr_accessor :credentials

    def initialize(credentials)
      @credentials = credentials
    end

    def send(path: '/api/v1/public/test', params: {})
			if path.start_with?('/api/v1/private/')
				headers = {"x-deribit-sig" => generate_signature(path, params)}
				response = self.class.post(path, body: params, headers: headers)
			else
				response = self.class.get(path, query: params)
			end

      raise Error.new(code: response.code) if Error.is_error_response?(response: response)

      json = JSON.parse(response.body, symbolize_names: true)

      raise Error.new(message: "Failed: " + json[:message]) unless json[:success]

      if json.include?(:result)
        json[:result]
      elsif json.include?(:message)
        json[:message]
      else
        "ok"
      end
    end

    def generate_signature(path, params={})
      timestamp = Time.now.utc.to_i + 1000

      signature_data = {
        _:       timestamp,
        _ackey:  credentials.api_key,
        _acsec:  credentials.api_secret,
        _action: path
       }

      signature_data.update(params)
      sorted_signature_data = signature_data.sort

      converter = ->(data){
        key = data[0]
        value = data[1]
        if value.is_a?(Array)
          [key.to_s, value.join].join('=')
        else
          [key.to_s, value.to_s].join('=')
        end
      }

      items = sorted_signature_data.map(&converter)
      signature_string = items.join('&')

      sha256 = OpenSSL::Digest::SHA256.new
      sha256_signature = sha256.digest(signature_string.encode('utf-8'))

      base64_signature = Base64.encode64(sha256_signature).encode('utf-8')

      [credentials.api_key, timestamp, base64_signature].join('.')
    end

  end
end
