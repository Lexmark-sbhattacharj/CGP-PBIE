# frozen_string_literal: true

class PowerBIServiceTest < ActiveSupport::TestCase
  VCR.configure do |config|
    config.cassette_library_dir = 'fixtures/vcr_cassettes'
    config.hook_into :webmock
  end

  test 'generates a new token when expired' do
    VCR.use_cassette('refresh_token') do
      report_id = '083f20d3-8f12-4cf3-9930-ba89612e80a4'
      workspace_id = '23269a7d-a364-4ef3-b85d-5ca8c9730b46'
      dataset_id = '34685ffd-5dbe-4d00-85b7-4d5c44b95b14'
      current_user = User.first
      access_token = PowerBIService.get_report_token(report_id, workspace_id, dataset_id, current_user)

      refreshed_token = PowerBIService.refresh_token(report_id, workspace_id, dataset_id, current_user)

      assert access_token['expiration'] != refreshed_token['expiration']
    end
  end

  test 'generates powerbi report token' do
    VCR.use_cassette('power_bi_report_token') do
      report_id = '4f01205a-20d3-4759-af3b-2c73a13e1087'
      workspace_id = '5ee276ae-2485-4f3d-a453-db6d74869186'
      dataset_id = '34afc64f-689f-4811-a138-4af2017921ea'
      current_user = User.first
      assert PowerBIService.get_report_token report_id, workspace_id, dataset_id, current_user
    end
  end

  test 'support for report tokens with datasets using effective identity' do
    dataset_id = '123456'
    dataset_metadata = {
      'isEffectiveIdentityRequired' => true
    }
    current_user = User.first
    body = PowerBIService.build_request_body_for_report_token(dataset_id, dataset_metadata, current_user)
    assert body.key?(:accessLevel)
    assert body.key?(:identities)
  end

  test 'support for report tokens with datasets without effective identity' do
    dataset_id = '123456'
    dataset_metadata = {}
    current_user = User.first
    body = PowerBIService.build_request_body_for_report_token(dataset_id, dataset_metadata, current_user)
    assert body.key?(:accessLevel)
    refute body.key?(:identities)
  end
end
