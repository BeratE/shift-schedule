module Hooks
  class ShiftScheduleViewHooks < Redmine::Hook::ViewListener
    render_on :view_my_account, :partial => "account_settings/schedule_account_settings"
  end
end
