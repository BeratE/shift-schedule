require 'date'

class SchedulesController < ApplicationController
  unloadable

  def index
    #show schedule of current week
    @curr_time = Time.new
    #@schedules = Schedule.where(year: curr_time.year, week: curr_time.strftime("%V"))
  end

  def edit

  end
end
