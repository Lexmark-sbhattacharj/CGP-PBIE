# frozen_string_literal: true

class MaintenanceController < ApplicationController
  layout false
  before_action :maintenance_page

  def show; end

  private

  def maintenance_page
    redirect_to '/' unless isMaintenance?
  end
end
