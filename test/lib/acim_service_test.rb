# frozen_string_literal: true

class ACIMServiceTest < ActiveSupport::TestCase
  VCR.configure do |config|
    config.cassette_library_dir = 'fixtures/vcr_cassettes'
    config.hook_into :webmock
  end

  test 'does not create a user that already exists' do
    VCR.use_cassette('acim_user_creation') do
      resp = ACIMService.create_user('creighton.medley@lexmark.fr')
      puts(resp)
      assert resp['error'] = 'User [creighton.medley@lexmark.fr] already exists.'
    end
  end
end
