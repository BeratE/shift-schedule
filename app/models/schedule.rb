class Schedule < ActiveRecord::Base
  unloadable

  validates :year, presence: true
  validates :week, presence: true
  validates :user_id, presence: true
  validates :version_id, presence: true
  validates :hours, presence: true
end
