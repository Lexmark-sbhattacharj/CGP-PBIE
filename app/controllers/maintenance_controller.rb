class MaintenanceController < ApplicationController
    layout false
    before_action :maintenance_page

    def show
    end

    private
    def maintenance_page
        if !isMaintenance?
            redirect_to '/'
        end
    end
end