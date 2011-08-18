class Event < ActiveRecord::Base
  has_many :checkins
  has_many :users, :through => :checkins
  belongs_to :creator, :class_name => "User"

  attr_accessor :current_user
  attr_accessible :name, :description, :start_date, :end_date
  scope :current, :conditions => "events.end_date >= (SELECT date('now'))", :order => "events.end_date ASC"

  def is_checked_in? user=nil
    user ||= current_user
    !users.find_by_id(user).nil?
  end

  def checkin user
    self.checkins.create(:user => user)
  end
end
