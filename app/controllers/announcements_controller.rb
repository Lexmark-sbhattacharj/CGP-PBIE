class AnnouncementsController < ApplicationController
    before_action :show_maintenance_page, except: [:destroy]
    def new
        @announcements=Announcement.new
    end
    def create
        @announcements=Announcement.new(announcement_params)
        if @announcements.save
          redirect_to @announcements
        else
          render 'new'
        end
    end
    def show
        @announcements = Announcement.find(params[:id])
    end
    def edit
        @announcements = Announcement.find(params[:id])
    end
    def index 
        @announcements = Announcement.all.order(created_at: :DESC)
    end
    def update 
        @announcements = Announcement.find(params[:id])
        if @announcements.update(update_announcement_params)
          redirect_to @announcements
        else
          render 'edit'
        end  
    end
    def destroy
        @announcements = Announcement.find(params[:id])
        if @announcements.scope != "Global"
            workspace = Workspace.find_by(name: @announcements.scope)
            workspace.maintain = false
            workspace.save
        end   
        @announcements.destroy
        redirect_to announcements_path
    end
    def announcement_params
        params.require(:announcements).permit(:title, :start_date, :end_date, :scope)
    end
    def update_announcement_params
        params.require(:announcement).permit(:title, :start_date, :end_date)
    end
end