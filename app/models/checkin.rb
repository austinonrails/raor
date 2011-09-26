class Checkin < ActiveRecord::Base
  belongs_to :event
  belongs_to :user

  attr_accessor :current_user
  attr_accessible :employ, :employment, :event_id, :shoutout, :user_id, :as => :default
  attr_accessible :created_at, :employ, :employment, :event_id, :hidden, :shoutout, :updated_at, :user_id, :as => :admin

  scope :hidden, :conditions => ["checkins.hidden = ?", true]
  scope :unhidden, :conditions => ["checkins.hidden = ?", false]

  validates :employ, :inclusion => {:in => [true, false]}
  validates :employment, :inclusion => {:in => [true, false]}
  validate :is_user
  validates :shoutout, :format => {:with => /^[\x20-\x7E]*$/}, :length => {:within => 0..254}

  private
  def is_user
    errors[:base] << "Attempting to checkin as another user is a no-no!" unless self.current_user.present? && self.user_id == self.current_user.id
  end
end
