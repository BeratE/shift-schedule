Redmine::Plugin.register :shift_schedule do
  name 'Shift Schedule'
  author 'Berat Ertural'
  description 'This is a plugin for scheduling the developer shifts on different projects and version.'
  version '0.0.1'
  url 'https://github.com/BeratE/shift-schedule'

  menu :top_menu, :schedules, { :controller => 'schedules', :action => 'index' }, :caption => 'Schedule'
  settings :default => {'empty' => true}, :partial => 'settings/schedule_settings'
end
