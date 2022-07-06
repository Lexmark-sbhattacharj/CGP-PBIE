# frozen_string_literal: true

class ContactusController < ApplicationController
  def index
    @contactus = params[:contactusmodels]
  end

  def create
    # raise Contactus.inspect
    @contactus = Contactusmodel.new(contactus_params)

    if @contactus.save
      ContactusmailerMailer.with(contactusmodels: @contactus).contactus_mailer.deliver_now!
    else
      'Error'
    end
  end

  def contactus_params
    params.require(:contactusmodels).permit(:name, :email, :comments)
  end
end
