require 'date'
class SchedulesController < ApplicationController
  unloadable

  #show schedules and navigation
  def index
    @curr_date = Time.new
    if params[:schedule_date].present? && vali_date(params[:schedule_date].to_time) then
      @curr_date = params[:schedule_date].to_time
    end
    session[:curr_date] = @curr_date

    #get all schedules and versions for the selected week
    @schedules = Schedule.where(year: @curr_date.year, week: @curr_date.strftime("%V").to_i)
    @versions = Version.joins("JOIN schedules ON schedules.version_id = versions.id
    WHERE schedules.year = #{@curr_date.year} AND schedules.week = #{@curr_date.strftime("%V").to_i}").distinct
    @users = get_users

    #sort all schedules in a 2d hash with [[user.id, version.id]] = hours, if any user is not assigned, new schedules will be created
    @schedhash = Hash.new
    @versions.each do |version|
      @users.each do |user|
        schedule = @schedules.find_by(user_id: user.id, version_id: version.id)
        if (schedule.nil?) then #create new schedules
          @versions.each do |v|
            Schedule.create(:year => @curr_date.year.to_i, :week => @curr_date.strftime("%V").to_i,
            :user_id => user.id, :version_id => v.id, :hours => 0)
            @schedhash[[user.id, v.id]] = 0
          end
        else
          @schedhash[[user.id, version.id]] = schedule.hours
        end
      end
    end
  end


  #show all versions who havent been added to the selected week for scheduling
  def new
    @curr_date = session[:curr_date]
    @versions = Version.find_by_sql("SELECT versions.id, versions.name
    FROM versions LEFT OUTER JOIN (SELECT * FROM schedules
    WHERE schedules.year = #{@curr_date.year} AND schedules.week = #{@curr_date.strftime("%V").to_i}) s
    ON versions.id = s.version_id WHERE s.id is NULL")
  end


  #create new schedules with selected version for the week
  def create
    if ((0..4294967295).include?(params[:v].to_i)) then
      @users = User.where(type: "User")
      @users.each do |u|
        Schedule.create(:year => session[:curr_date].year.to_i, :week => session[:curr_date].strftime("%V").to_i,
        :user_id => u.id, :version_id => params[:v].to_i, :hours => 0)
      end
    end

    redirect_to controller: 'schedules', action: 'index', schedule_date: session[:curr_date].strftime('%Y %m %d').gsub!(' ','-')
  end


  #change hours of all edited schedules
  def edit

  end


private
  #get all users that have a budget (shift_hours) configured
  def get_users
    User.joins("INNER JOIN user_preferences
    ON user_preferences.user_id = users.id
    AND user_preferences.shift_hours > 0").select(:id, :type, :firstname, :lastname, :shift_hours)
  end


  #validate the given date parameters
  def vali_date (date)
    return ((0..9999).include?(date.year) && (0..52).include?(date.strftime("%V").to_i))
  end
end
