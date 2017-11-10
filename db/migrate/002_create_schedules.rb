class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :year, :null => false
      t.integer :week, :null => false
      t.references :user, index: true, :null => false
      t.references :version, index: true, :null => false
      t.references :project, index: true, :null => false
      t.integer :hours, :default => 0
    end
  end
end
