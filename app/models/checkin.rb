class Checkin < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  attr_accessible :user_id, :employment, :employ, :shoutout, :event_id, :as => :default
  attr_accessible :user_id, :employment, :employ, :shoutout, :event_id, :created_at, :updated_at, :as => :admin
end
