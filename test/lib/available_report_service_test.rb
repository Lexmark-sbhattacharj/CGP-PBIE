# frozen_string_literal: true

class AvailableReportServiceTest < ActiveSupport::TestCase
  VCR.configure do |config|
    config.cassette_library_dir = 'fixtures/vcr_cassettes'
    config.hook_into :webmock
  end

  test 'generates manifest of available reports at run time' do
    VCR.use_cassette('available_report_history') do
      assert AvailableReportHistory.count.zero?
      AvailableReportService.run_available_reports
      assert AvailableReportHistory.count.positive?
    end
  end
end
