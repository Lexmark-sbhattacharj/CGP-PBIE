class AnnouncementsController < ApplicationController
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
        if @announcements.update(announcement_params)
          redirect_to @announcement
        else
          render 'edit'
        end  
    end
    def destroy
        @announcements = Announcement.find(params[:id])
        @announcements.destroy
        redirect_to announcements_path
    end
    def announcement_params
        params.require(:announcements).permit(:title, :start_date, :end_date)
    end
end