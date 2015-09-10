class Roster < ActiveRecord::Base

validates_uniqueness_of :user_id, scope: :meetup_id

  belongs_to :user
  belongs_to :meetup
end
