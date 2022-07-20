class Announcement < ApplicationRecord
    validates :title, presence: true
    validates :start_date, presence: true
    validates :end_date, presence: true
    validates :scope, presence: true
end
