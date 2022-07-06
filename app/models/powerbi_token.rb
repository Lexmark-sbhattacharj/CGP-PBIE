# frozen_string_literal: true

# model for managing powerbi tokens
class PowerbiToken < ApplicationRecord
  def self.instance
    first || create
  end

  def pbi_access_token
    if expires.nil? || (expires < Time.now)
      refresh_token
    else
      access_token
    end
  end

  private

  def refresh_token
    token = PowerBIService.powerbi_token
    self.access_token = token['access_token']
    self.expires = Time.now + token['expires_in'].to_i
    save
    access_token
  end
end
