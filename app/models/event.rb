class Event < ActiveRecord::Base
  has_many :checkins
  has_many :users, :through => :checkins
  
  scope :current, :conditions => "events.end_date >= (SELECT date('now'))"

  def is_checked_in? user
    !users.find_by_id(user).nil?
  end

  def checkin user
    self.checkins.create(:user => user)
  end
end
