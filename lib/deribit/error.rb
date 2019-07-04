module Deribit
  class Error < StandardError
    attr_reader :code, :msg

    def initialize(code: nil, json: {}, message: nil)
      @code = code || json[:code]
      @msg = message || json[:msg]
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
