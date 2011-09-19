class Event < ActiveRecord::Base
  has_many :checkins
  has_many :users, :through => :checkins
  belongs_to :creator, :class_name => "User"

  attr_accessor :current_user
  attr_accessible :name, :description, :start_date, :end_date, :as => :default
  attr_accessible :id, :name, :description, :start_date, :end_date, :creator_id, :created_at, :updated_at, :as => :admin
  scope :current, :conditions => "events.end_date >= (SELECT date('now'))", :order => "events.end_date ASC"
  scope :active, :conditions => ["events.end_date > ? AND events.start_date <= ?", Time.now, Time.now]

  def is_checked_in? user=nil
    user ||= current_user
    !users.find_by_id(user).nil?
  end

  def checkin user
    self.checkins.create(:user => user)
  end
end
