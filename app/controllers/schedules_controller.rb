require 'date'
class SchedulesController < ApplicationController
  before_action :require_login
  before_action :require_project, :authorize, :except => [:index, :sel_pr]

  #list projects current user is involved in
  def index
    if session[:project_id]
      @project = Project.find(session[:project_id])
      redirect_to controller: 'schedules', action: 'view'
    end

    @projects = Project.find_by_sql("SELECT projects.id, projects.name, projects.description
      FROM projects JOIN members ON members.project_id = projects.id
      JOIN users ON members.user_id = users.id
      WHERE users.id = #{User.current.id}")
  end

  def sel_pr
    session.delete(:project_id)
    redirect_to controller: 'schedules', action: 'index'
  end

  #show schedules of selected project, show navigation and do some initialization
  def view
    @curr_date = Time.new
    if params[:schedule_date].present? && vali_date(params[:schedule_date].to_time)
      @curr_date = params[:schedule_date].to_time
    end
    session[:curr_date] = @curr_date

    @schedules = get_schedules_current
    @versions = get_versions_current
    @users = get_users_current
    @schedhash = get_schedhash(@schedules, @users, @versions)

    @project = Project.find(session[:project_id])
  end

  #show all versions of selected project who havent been added to the selected week for scheduling
  def new
    @curr_date = session[:curr_date]
    @versions = Version.find_by_sql("SELECT versions.id, versions.name, pr.name AS pname
    FROM versions JOIN (SELECT * FROM projects WHERE projects.id = #{session[:project_id].to_i}) pr
    ON versions.project_id = pr.id
    LEFT OUTER JOIN (SELECT * FROM schedules
    WHERE schedules.year = #{@curr_date.year} AND schedules.week = #{@curr_date.strftime("%V").to_i}) s
    ON versions.id = s.version_id WHERE s.id is NULL")
  end

  #create new schedules for of current week for selected version
  def create
    if ((params[:_id].to_i).is_a? Integer)
      @users = get_users_current
      @users.each do |u|
        Schedule.create(:year => session[:curr_date].year.to_i, :week => session[:curr_date].strftime("%V").to_i,
        :user_id => u.id, :version_id => params[:_id].to_i, :project_id => session[:project_id], :hours => 0)
      end
    end
    redirect_to controller: 'schedules', action: 'view', schedule_date: form_date
  end

  #delete all schedules of current week for the selected version
  def delete
    if ((params[:_id].to_i).is_a? Integer)
      Schedule.where(:year => session[:curr_date].year.to_i, :week => session[:curr_date].strftime("%V").to_i,
      :version_id => params[:_id].to_i).destroy_all
    end
    redirect_to controller: 'schedules', action: 'view', schedule_date: form_date
  end

  #change hours of all edited schedules
  def edit
    @curr_date = session[:curr_date]
    @users = get_users_current
    @versions = get_versions_current
    @schedules = get_schedules_current

    @users.each do |u|
      @versions.each do |v|
        sched = @schedules.find_by(user_id: u.id, version_id: v.id)
        sched.hours = params["#{u.id}|#{v.id}"].to_i
        sched.save
      end
    end

    redirect_to controller: 'schedules', action: 'view', schedule_date: form_date
  end

private
  #load the project for the purpose of authorizing
  def require_project
    if (!session[:project_id] && params[:_id])
      session[:project_id] = params[:_id]
    end
    @project = Project.find(session[:project_id])
  end

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

  #get all users that are assigned to the project and have a budget (shift_hours) configured
  def get_users_current
    User.find_by_sql("SELECT users.id, users.type, users.firstname, users.lastname, up.shift_hours
    FROM users JOIN (SELECT * FROM members WHERE members.project_id = #{session[:project_id].to_i}) m ON m.user_id = users.id
    INNER JOIN (SELECT * FROM user_preferences WHERE user_preferences.shift_hours > 0) up ON up.user_id = users.id")
  end

  #get all schedules for the selected project and current week
  def get_schedules_current
    Schedule.where(project_id: session[:project_id], year: session[:curr_date].year, week: session[:curr_date].strftime("%V").to_i)
  end

  #get all disctinct versions of selected project scheduled for the current week
  def get_versions_current
    Version.find_by_sql("SELECT DISTINCT versions.id, versions.name, pr.name AS pname
    FROM versions JOIN schedules ON schedules.version_id = versions.id
    JOIN (SELECT * FROM projects WHERE projects.id = #{session[:project_id].to_i}) pr ON versions.project_id = pr.id
    WHERE schedules.year = #{session[:curr_date].year} AND schedules.week = #{session[:curr_date].strftime("%V").to_i}")
  end

  #sort all schedules in a 2d hash, if any user is not assigned, new schedules will be created
  def get_schedhash (schedules, users, versions)
    curr_date = session[:curr_date]
    schedhash = Hash.new # all schedules stored in a 2d hash [[user.id, version.id]] = hours, for ease of use
    versions.each do |version|
      users.each do |user|
        schedule = schedules.find_by(user_id: user.id, version_id: version.id)
        unless (schedule.nil?)
          schedhash[[user.id, version.id]] = schedule.hours
        else #a new user has come: create new schedules
          versions.each do |v|
            Schedule.create(:year => curr_date.year.to_i, :week => curr_date.strftime("%V").to_i,
            :user_id => user.id, :version_id => v.id, :project_id => session[:project_id], :hours => 0)
            schedhash[[user.id, v.id]] = 0
          end
        end
      end
    end
    return schedhash
  end

  #formats the date into the fitting paramenter formats
  def form_date
    return session[:curr_date].strftime('%Y %m %d').gsub!(' ','-')
  end
end
