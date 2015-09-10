class Meetup < ActiveRecord::Base

  validates_uniqueness_of :title, scope: :location

  has_many :rosters
  has_many :users,
    through: :rosters
end
