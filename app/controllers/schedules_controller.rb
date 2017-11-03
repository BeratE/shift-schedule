require 'date'
class SchedulesController < ApplicationController
  before_action :require_login
  unloadable

  #show schedules and navigation and do some initialization
  def index
    @curr_date = Time.new
    if params[:schedule_date].present? && vali_date(params[:schedule_date].to_time)
      @curr_date = params[:schedule_date].to_time
    end
    session[:curr_date] = @curr_date

    @schedules = get_schedules_current
    @versions = get_versions_current
    @users = get_users

    @schedhash = Hash.new # all schedules stored in a 2d hash [[user.id, version.id]] = hours, for ease of use

    #sort all schedules in 2d hash if any user is not assigned, new schedules will be created
    @versions.each do |version|
      @users.each do |user|
        schedule = @schedules.find_by(user_id: user.id, version_id: version.id)
        unless (schedule.nil?)
          @schedhash[[user.id, version.id]] = schedule.hours
        else #create new schedules
          @versions.each do |v|
            Schedule.create(:year => @curr_date.year.to_i, :week => @curr_date.strftime("%V").to_i,
            :user_id => user.id, :version_id => v.id, :hours => 0)
            @schedhash[[user.id, v.id]] = 0
          end
        end
      end
    end
  end

  #show all versions who havent been added to the selected week for scheduling
  def new
    @curr_date = session[:curr_date]
    @versions = Version.find_by_sql("SELECT versions.id, versions.name, projects.name AS pname
    FROM versions JOIN projects ON versions.project_id = projects.id
    LEFT OUTER JOIN (SELECT * FROM schedules
    WHERE schedules.year = #{@curr_date.year} AND schedules.week = #{@curr_date.strftime("%V").to_i}) s
    ON versions.id = s.version_id WHERE s.id is NULL")
  end

  #create new schedules of current week for selected version
  def create
    if ((params[:v_id].to_i).is_a? Integer)
      @users = User.where(type: "User") # all users so users with unconfigured budget have a schedule
      @users.each do |u|
        Schedule.create(:year => session[:curr_date].year.to_i, :week => session[:curr_date].strftime("%V").to_i,
        :user_id => u.id, :version_id => params[:v_id].to_i, :hours => 0)
      end
    end
    redirect_to controller: 'schedules', action: 'index', schedule_date: session[:curr_date].strftime('%Y %m %d').gsub!(' ','-')
  end

  #delete all schedules of current week for the selected version
  def delete
    if ((params[:v_id].to_i).is_a? Integer)
      Schedule.where(:year => session[:curr_date].year.to_i, :week => session[:curr_date].strftime("%V").to_i,
      :version_id => params[:v_id].to_i).destroy_all
    end
    redirect_to controller: 'schedules', action: 'index', schedule_date: session[:curr_date].strftime('%Y %m %d').gsub!(' ','-')
  end

  #change hours of all edited schedules
  def edit
    @curr_date = session[:curr_date]
    @users = get_users
    @schedules = get_schedules_current
    @versions = get_versions_current

    @users.each do |u|
      @versions.each do |v|
        sched = @schedules.find_by(user_id: u.id, version_id: v.id)
        sched.hours = params["#{u.id}|#{v.id}"].to_i
        sched.save
      end
    end

    redirect_to controller: 'schedules', action: 'index', schedule_date: session[:curr_date].strftime('%Y %m %d').gsub!(' ','-')
  end

private
  #checks if the user is logged in and configures the time unless already set
  def require_login
    unless User.current.logged?
      redirect_to "/"
    end
    unless session[:curr_date]
      session[:curr_date] = Time.new
    end
  end

  #validate the given date parameters
  def vali_date (date)
    return ((0..9999).include?(date.year) && (0..52).include?(date.strftime("%V").to_i))
  end

  #get all users that have a budget (shift_hours) configured
  def get_users
    User.joins("INNER JOIN user_preferences
    ON user_preferences.user_id = users.id
    AND user_preferences.shift_hours > 0").select(:id, :type, :firstname, :lastname, :shift_hours)
  end

  #get all schedules for the current week
  def get_schedules_current
    Schedule.where(year: session[:curr_date].year, week: session[:curr_date].strftime("%V").to_i)
  end

  #get all disctinct versions scheduled for the current week
  def get_versions_current
    Version.find_by_sql("SELECT DISTINCT versions.id, versions.name, projects.name AS pname
    FROM versions JOIN schedules ON schedules.version_id = versions.id JOIN projects ON versions.project_id = projects.id
    WHERE schedules.year = #{session[:curr_date].year} AND schedules.week = #{session[:curr_date].strftime("%V").to_i}")
  end
end
