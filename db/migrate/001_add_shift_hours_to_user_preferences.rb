class AddShiftHoursToUserPreferences < ActiveRecord::Migration
  def up
    add_column :user_preferences, :shift_hours, :float
  end

  def down
    remove_column :user_preferences, :shift_hours
  end
end
