Redmine::Plugin.register :shift_schedule do
  require_dependency 'hooks/shift_schedule_view_hooks'

  name 'Shift Schedule'
  author 'Berat Ertural'
  description 'Plugin for scheduling the weekly developer shifts onto different versions of projects.'
  version '0.1.0'
  url 'https://github.com/BeratE/shift-schedule'

  menu :top_menu, :schedules, { :controller => 'schedules', :action => 'index' }, :caption => 'Schedule', :if => Proc.new{User.current.logged?}
  settings :default => {'budget_buffer' => 20}, :partial => 'settings/schedule_settings'

  permission :view_schedules, { :schedules => [:view] }
  permission :edit_schedules, { :schedules => [:view, :new, :edit, :create, :delete] }
end
