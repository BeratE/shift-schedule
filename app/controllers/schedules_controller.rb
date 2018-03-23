require 'date'
class SchedulesController < ApplicationController
  before_action :require_login
  before_action :require_project, :authorize, :except => [:index, :sel_pr, :users]

  #list projects current user is involved in
  def index
    #if a project had been selected before and user has permissions, redirect to view
    @project = nil
    if session[:project_id]
      pr = Project.find(session[:project_id])
      if (user_has_permission?(User.current, pr))
        @project = pr;
        redirect_to controller: 'schedules', action: 'view'
      else
        session.delete(:project_id)
      end
    end

    #select all projects that have versions and where the user is involved
    @projects = Project.find_by_sql("SELECT projects.*
      FROM projects JOIN members ON members.project_id = projects.id
      JOIN users ON members.user_id = users.id
      WHERE users.id = #{User.current.id} AND
      EXISTS (SELECT versions.project_id FROM versions WHERE versions.status = 'open' AND projects.id = versions.project_id)
      ORDER BY projects.created_on DESC").reject{ |j|
        !user_has_permission?(User.current, j)
      }
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

    @project = Project.find(session[:project_id])
    @users = get_users_current(@project)
    @versions = get_versions_current
    @logged_times = get_logged_times
    @scheduled_times = get_scheduled_times
    @schedules = get_schedules_current
    @schedhash = get_schedhash(@schedules, @users, @versions)
  end

  #show all versions of selected project who havent been added to the selected week for scheduling
  def new
    @curr_date = session[:curr_date]
    @versions = Version.find_by_sql("SELECT DISTINCT versions.id, versions.name, pr.name AS pname
    FROM versions JOIN (SELECT * FROM projects WHERE projects.id = #{session[:project_id].to_i}) pr
    ON versions.project_id = pr.id LEFT OUTER JOIN (SELECT * FROM schedules
    WHERE schedules.year = #{@curr_date.year} AND schedules.week = #{@curr_date.strftime("%V").to_i}) s
    ON versions.id = s.version_id WHERE s.id is NULL AND versions.status = 'open'")
  end

  #create new schedules of current week for selected version
  def create
    if ((params[:_id].to_i).is_a? Integer)
      users = get_users_current(Project.find(session[:project_id]))
      users.each do |u|
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
    versions = get_versions_current
    schedules = get_schedules_current
    users = get_users_current(Project.find(session[:project_id]))

    users.each do |u|
      versions.each do |v|
        sched = schedules.find_by(user_id: u.id, version_id: v.id)
        sched.hours = params["#{u.id}|#{v.id}"].to_f.abs
        sched.save
      end
    end

    redirect_to controller: 'schedules', action: 'view', schedule_date: form_date
  end

  def users
    @curr_date = Time.now
    @project = Project.find(session[:project_id])
    @users = get_users_current(@project)
    @versions = Schedule.find_by_sql("SELECT DISTINCT schedules.version_id, versions.name AS version_name,
    projects.id AS project_id, projects.name AS project_name
    FROM schedules JOIN versions ON schedules.version_id = versions.id JOIN projects
    ON versions.project_id = projects.id WHERE schedules.year = #{@curr_date.year}")
    @schedules = Schedule.find_by_sql("SELECT schedules.user_id, schedules.week, schedules.version_id, SUM(schedules.hours) AS hours
    FROM schedules WHERE schedules.year = #{@curr_date.year} GROUP BY schedules.user_id, schedules.version_id, schedules.week")
  end

############################################################################################################################################
############################################################################################################################################
private
  #load the project for the purpose of authorizing
  def require_project
    if (!session[:project_id] && params[:_id] && ((params[:_id].to_i).is_a? Integer))
      session[:project_id] = params[:_id].to_i
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

  #checks wether current user is allowed to view or edit the project
  def user_has_permission?(user, project)
    user.allowed_to?(:view_schedules, project) || user.allowed_to?(:edit_schedules, project)
  end

  #formats the date into the fitting paramenter formats
  def form_date
    return session[:curr_date].strftime('%Y %m %d').gsub!(' ','-')
  end

  #get all users that are assigned to the project and have a budget (shift_hours) configured
  def get_users_current(project)
    User.find_by_sql("SELECT users.*, up.shift_hours
    FROM users JOIN (SELECT * FROM members WHERE members.project_id = #{session[:project_id].to_i}) m ON m.user_id = users.id
    INNER JOIN (SELECT * FROM user_preferences WHERE user_preferences.shift_hours > 0) up ON up.user_id = users.id").reject{ |u|
      !user_has_permission?(u, project)
    }
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
    WHERE schedules.year = #{session[:curr_date].year} AND schedules.week = #{session[:curr_date].strftime("%V").to_i}
    AND versions.status = 'open'")
  end

  #get the logged times of users for a project(version) for the given week
  def get_logged_times
    TimeEntry.find_by_sql("SELECT issues.fixed_version_id AS version_id,
    time_entries.user_id, SUM(time_entries.hours) AS hours
    FROM time_entries JOIN issues ON time_entries.issue_id = issues.id
    WHERE time_entries.tyear = #{session[:curr_date].strftime("%Y")}
    AND time_entries.tweek = #{session[:curr_date].strftime("%V")}
    AND issues.fixed_version_id IS NOT NULL
    GROUP BY time_entries.user_id, issues.fixed_version_id")
  end

  #get the sum of the times a user has already scheduled for the given week
  def get_scheduled_times
    Schedule.find_by_sql("SELECT schedules.user_id, SUM(hours) AS hours
    FROM schedules WHERE schedules.year = #{session[:curr_date].strftime("%Y")}
    AND schedules.week = #{session[:curr_date].strftime("%V")} GROUP BY schedules.user_id")
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
end
