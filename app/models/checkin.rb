class Checkin < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  before_save :set_employer

  attr_accessor :current_user, :remember_employer
  attr_accessible :employ, :employer, :employment, :event_id, :remember_employer, :shoutout, :user_id, :as => :default
  attr_accessible :created_at, :employ, :employer, :employment, :event_id, :hidden, :remember_employer, :shoutout, :updated_at, :user_id, :as => :admin

  scope :hidden, :conditions => ["checkins.hidden = ?", true]
  scope :unhidden, :conditions => ["checkins.hidden = ?", false]
  scope :employ, :conditions => ["checkins.employ = ?", true]
  scope :employment, :conditions => ["checkins.employment = ?", true]

  validates :employ, :inclusion => {:in => [true, false]}
  validates :employment, :inclusion => {:in => [true, false]}
  validates :remember_employer, :inclusion => {:in => [true, false, "1", "0", 1, 0]}
  validates :employer, :format => {:with => /^[\x20-\x7E]*$/}, :length => {:within => 0..254}
  validate :is_user
  validates :shoutout, :format => {:with => /^[\x20-\x7E]*$/}, :length => {:within => 0..254}

  def remember_employer
    @remember_employer ||= current_user.remember_employer
  end

  private
  def is_user
    errors[:base] << "Attempting to checkin as another user is a no-no!" unless self.current_user.present? && self.user_id == self.current_user.id
  end

  def set_employer
    self.current_user.update_attributes(:employer => self.employer, :remember_employer => @remember_employer)
  end
end
