class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :year
      t.integer :week
      t.references :user, index: true
      t.references :version, index: true
      t.integer :hours
    end

    add_index :schedules, [:year, :week], :unique => true
  end
end
