class Event < ActiveRecord::Base
  has_many :checkins
  belongs_to :creator, :class_name => "User"
  has_many :users, :through => :checkins

  attr_accessor :current_user
  attr_accessible :description, :end_date, :name, :start_date, :as => :default
  attr_accessible :created_at, :creator_id, :description, :end_date, :id, :name, :start_date, :updated_at, :as => :admin

  scope :active, :conditions => ["events.end_date > ? AND events.start_date <= ?", Time.now, Time.now]
  scope :current, :conditions => "events.end_date >= (SELECT date('now'))", :order => "events.end_date ASC"

  def is_checked_in user=nil
    user ||= current_user
    !users.find_by_id(user).nil?
  end

  def checkin user
    self.checkins.create(:user => user)
  end
end
