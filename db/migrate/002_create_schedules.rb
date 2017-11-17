class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :year, :null => false
      t.integer :week, :null => false
      t.references :user, index: true, :null => false, :dependent => :delete
      t.references :version, index: true, :null => false, :dependent => :delete
      t.references :project, index: true, :null => false, :dependent => :delete
      t.float :hours, :default => 0
    end
  end
end
