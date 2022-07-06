# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'cgp.reporting@lexmark.com'
  layout 'mailer'
end
