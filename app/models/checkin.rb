class Checkin < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  attr_accessible :user_id, :employment, :employ, :shoutout
end
