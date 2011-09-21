class Checkin < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  attr_accessible :employ, :employment, :event_id, :shoutout, :user_id, :as => :default
  attr_accessible :created_at, :employment, :employ, :event_id, :hidden, :shoutout, :updated_at, :user_id, :as => :admin

  scope :hidden, :conditions => ["checkins.hidden = ?", true]
  scope :unhidden, :conditions => ["checkins.hidden = ?", false]
end
