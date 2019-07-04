require 'deribit/version'
require 'deribit/methods'
require 'deribit/immutable_header_key'
require 'deribit/error'
require 'deribit/request'
require 'deribit/api'
require 'deribit/ws'
require 'deribit/ws/handler'

module Deribit
  API_VERSION = 'v2'
  DEFAULT_REQUEST_PATH = "/api/#{API_VERSION}/public/test"
  SERVER_URL = 'https://www.deribit.com/'
  TEST_URL = 'https://test.deribit.com/'
  API_PATH = "api/#{API_VERSION}/"

  WS_SERVER_URL = "wss://www.deribit.com/ws/api/#{API_VERSION}/"
  WS_TEST_URL = "wss://test.deribit.com/ws/api/#{API_VERSION}/"
end
