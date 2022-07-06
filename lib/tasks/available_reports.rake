# frozen_string_literal: true

task available_reports: :environment do
  AvailableReportService.run_available_reports
end
