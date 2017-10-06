require 'date'

class SchedulesController < ApplicationController
  unloadable

  def index
    #show schedule of selected (or current if nothing selected) week
    @curr_date = Time.new
    if params[:schedule_date].present? then
      @curr_date = params[:schedule_date].to_time
    end
    @schedules = Schedule.where(year: @curr_date.year, week: @curr_date.strftime("%V").to_i).to_a
    @users = User.joins("INNER JOIN user_preferences
                         ON user_preferences.user_id = users.id
                         AND user_preferences.shift_hours > 0").select(:id, :type, :firstname, :lastname, :shift_hours)
  end

  def edit

  end
end
