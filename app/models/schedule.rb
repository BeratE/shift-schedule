class Schedule < ActiveRecord::Base
  unloadable

  belongs_to :user
  belongs_to :version

  validates :year, presence: true
  validates :week, presence: true
  validates :user, presence: true
  validates :version, presence: true
  validates :hours, presence: true
end
