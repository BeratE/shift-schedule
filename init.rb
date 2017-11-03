Redmine::Plugin.register :shift_schedule do
  require_dependency 'hooks/shift_schedule_view_hooks'

  name 'Shift Schedule'
  author 'Berat Ertural'
  description 'Plugin for scheduling the weekly developer shifts on different projects and version.'
  version '0.2.0'
  url 'https://github.com/BeratE/shift-schedule'

  menu :top_menu, :schedules, { :controller => 'schedules', :action => 'index' }, :caption => 'Schedule', :if => Proc.new{User.current.logged?}
  settings :default => {'budget_buffer' => 20}, :partial => 'settings/schedule_settings'
end
