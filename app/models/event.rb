class Event < ActiveRecord::Base
  has_many :checkins
  has_many :users, :through => :checkins
  
  scope :current, :conditions => "events.end_date >= (SELECT date('now'))", :order => "events.end_date ASC"

  def is_checked_in? user
    !users.find_by_id(user).nil?
  end

  def checkin user
    self.checkins.create(:user => user)
  end
end
