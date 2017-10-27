module SchedulesHelper
  def ava_time (user)
    return (user.shift_hours.to_i * (1 - (Setting.plugin_shift_schedule['buffer'].to_i / 100.0))).to_i
  end

  def sum_user_time (user, versions, schedhash)
    sum = 0
    versions.each do |v|
      sum = sum + schedhash[[user.id, v.id]]
    end
    return sum
  end

  def sum_version_time (version, users, schedhash)
    sum = 0
    users.each do |u|
      sum = sum + schedhash[[u.id, version.id]]
    end
    return sum
  end

  def sum_user_version_time (users, versions, schedhash)
    users_sum = 0
    users.each do |u|
      users_sum = users_sum + ava_time(u)
    end
    versions_sum = 0
    versions.each do |v|
      versions_sum = versions_sum + sum_version_time(v, users, schedhash)
    end

    return "#{versions_sum} / #{users_sum}"
  end

  def format_time (date)
    return date.strftime('%Y %m %d').gsub!(' ','-')
  end
end
