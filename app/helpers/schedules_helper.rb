module SchedulesHelper
  def ava_time (user)
    return user.shift_hours.to_i * (1 - (Setting.plugin_shift_schedule['buffer'].to_i / 100.0))
  end

  def format_time (date)
    return date.strftime('%Y %m %d').gsub!(' ','-')
  end
end
