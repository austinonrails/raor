class Event < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  has_many :checkins
  belongs_to :creator, :class_name => "User"
  has_many :users, :through => :checkins

  attr_accessor :current_user
  attr_accessible :description, :end_date, :end_time, :name, :start_date, :start_time, :as => :default
  attr_accessible :created_at, :creator_id, :description, :end_date, :end_time, :id, :name, :start_date, :start_time, :updated_at, :as => :admin

  validates :name, :format => {:with => /^[\x20-\x7E]+$/}, :length => {:within => 2..254}, :presence => true
  validates :description, :format => {:with => /^[\x20-\x7E]*$/}, :length => {:within => 0..254}
  validates :start_datetime, :date => {:before => :end_datetime}
  validates :start_datetime, :date => {:after => Proc.new {Time.zone.now - 5.minutes}}, :on => :create
  validates :end_datetime, :date => {:after => :start_datetime}

  def self.active
    where("\"events\".\"end_datetime\" > ? AND \"events\".\"start_datetime\" <= ?", Time.zone.now, Time.zone.now)
  end

  def self.current
    where("\"events\".\"end_datetime\" >= ?", Time.zone.now).order("\"events\".\"end_datetime\" ASC")
  end

  def active?
    now = Time.zone.now
    self.end_datetime > now && self.start_datetime <= now
  end

  def current_user
    @user
  end

  def current_user=(user)
    @user = user
    self.creator_id = user,id
  end

  def is_checked_in user=nil
    user ||= current_user
    !users.find_by_id(user).nil?
  end

  def is_in_rafflr user=nil
    user ||= current_user
    checkins.find_by_user_id(user).try(:rafflr)
  end

  def start_date
    self.start_datetime.to_date.to_s if self.start_datetime
  end

  def start_date=(value)
    self.start_datetime = Time.zone.parse("#{value} #{self.start_datetime.strftime('%I:%M %p') if self.start_datetime}")
  end

  def start_time
    self.start_datetime.strftime('%I:%M %p') if self.start_datetime
  end

  def start_time=(value)
    self.start_datetime = Time.zone.parse("#{self.start_datetime ? self.start_datetime.to_date.to_s : Time.zone.now.to_date.to_s} #{value} #{Time.zone.now.zone}")
  end

  def end_date
    self.end_datetime.to_date.to_s if self.end_datetime
  end

  def end_date=(value)
    self.end_datetime = Time.zone.parse("#{value} #{self.end_datetime.strftime('%I:%M %p') if self.end_datetime}")
  end

  def end_time
    self.end_datetime.strftime('%I:%M %p') if self.end_datetime
  end

  def end_time=(value)
    self.end_datetime = Time.zone.parse("#{self.end_datetime ? self.end_datetime.to_date.to_s : Time.zone.now.to_date.to_s} #{value} #{Time.zone.now.zone}")
  end
end
