# frozen_string_literal: true

class ContactusmailerMailer < ApplicationMailer
  def contactus_mailer
    @contactus = params[:contactusmodels]
    mail(to: 'sourish.bhattacharjee@lexmark.com', subject: 'You got a new comment - Contact Us')
  end
end
