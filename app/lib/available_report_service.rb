# frozen_string_literal: true

# methods for managing reports available at runtime
class AvailableReportService
  def self.run_available_reports
    Workspace.all.each do |workspace|
      next unless workspace.reports.key?('value')

      workspace.reports['value'].each do |report|
        save(report, workspace)
      end
    end
  end

  def self.save(report, workspace)
    arh = AvailableReportHistory.new
    arh.date_on = Time.now.strftime('%Y-%m-%d')
    arh.report_id = report['id']
    arh.report_name = report['name']
    arh.pbi_workspace_id = workspace.pbi_workspace_id
    arh.idempotence_key = workspace.id
    arh.save
  end
end
