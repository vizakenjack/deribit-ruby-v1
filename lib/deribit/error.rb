module Deribit
  class Error < StandardError
    attr_reader :code, :msg, :key

    def initialize(code: nil, key: nil, json: {}, message: nil)
      @code = code || json[:code]
      @msg = message || json[:msg]
      @key = key
      @msg = "Failed for #{key}: #{@msg}" if @key
    end

    def inspect
      message = ""
      message += "(#{code}) " unless code.nil?
      message += "#{msg}" unless msg.nil?
    end

    def message
      inspect
    end

    def to_s
      inspect
    end
  end
end
