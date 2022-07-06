# frozen_string_literal: true

require 'test_helper'

class PowerbiTokenTest < ActiveSupport::TestCase
  VCR.configure do |config|
    config.cassette_library_dir = 'fixtures/vcr_cassettes'
    config.hook_into :webmock
  end

  test 'gets a powerbi token' do
    VCR.use_cassette('powerbi token') do
      token = PowerbiToken.instance.pbi_access_token
      assert token
    end
  end
end
