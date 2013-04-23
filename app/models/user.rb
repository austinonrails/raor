class User < ActiveRecord::Base
  ROLES = %w[admin moderator author banned]
  
  devise :database_authenticatable, :rememberable, :trackable, :validatable, :omniauthable
  attr_accessible :api_key, :email, :employer, :name, :provider, :remember_employer, :remember_me, :roles, :user, :uid,
                  :user_tokens_attributes, :as => :default
  attr_accessible :created_at, :current_sign_in_at, :current_sign_in_ip, :email, :employer, :id, :last_sign_in_at, :last_sign_in_ip, :name,
                  :remember_created_at, :remember_employer, :sign_in_count, :updated_at, :user_tokens_attributes, :as => :admin

  has_many :checkins
  has_many :events, :through => :checkins
  has_many :user_tokens

  accepts_nested_attributes_for :user_tokens

  validates :name, :format => {:with => /\A[A-Za-z0-9_\s]+\z/}, :length => {:within => 2..254}, :presence => true
  validates :remember_employer, :inclusion => {:in => [true, false]}

  def self.find_for_twitter_oauth(omniauth, signed_in_resource=nil)
    authentication = UserToken.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication && authentication.user
      authentication.user
    else
      name = omniauth.info.name
      name = omniauth.info.nickname if name.blank?
      name = omniauth.extra.screen_name if name.blank?
      user = (User.find_by_email(omniauth.info.email) if omniauth.info.email) || User.create!(:name => name)
      if authentication
        authentication.user = user
      else
        UserToken.create!(:uid => omniauth["uid"], :provider => omniauth["provider"], :user => user)
      end
      user
    end
  end

  def self.find_for_facebook_oauth(omniauth, signed_in_resource=nil)
    authentication = UserToken.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication && authentication.user
      authentication.user
    else
      name = omniauth.info.name
      name = omniauth.info.nickname if name.blank?
      name = omniauth.extra.screen_name if name.blank?
      user = (User.find_by_email(omniauth.info.email) if omniauth.info.email) || User.create!(:name => name)
      if authentication
        authentication.user = user
      else
        UserToken.create!(:uid => omniauth["uid"], :provider => omniauth["provider"], :user => user)
      end
      user
    end
  end

  def self.find_for_github_oauth(omniauth, signed_in_resource=nil)
    authentication = UserToken.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'].to_s)
    if authentication && authentication.user
      authentication.user
    else
      name = omniauth.info.name
      name = omniauth.info.nickname if name.blank?
      name = omniauth.extra.screen_name if name.blank?
      user = (User.find_by_email(omniauth.info.email) if omniauth.info.email) || User.create!(:name => name)
      if authentication
        authentication.user = user
      else
        UserToken.create!(:uid => omniauth["uid"].to_s, :provider => omniauth["provider"], :user => user)
      end
      user
    end
  end

  def self.find_for_open_id(omniauth, signed_in_resource=nil)
    authentication = UserToken.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication && authentication.user
      authentication.user
    else
      user = User.find_by_email(omniauth.info.email) || User.create!(:name => omniauth.info.name, :email => omniauth.info.email)
      if authentication
        authentication.user = user
      else
        UserToken.create!(:uid => omniauth["uid"], :provider => omniauth["provider"], :user => user)
      end
      user
    end
  end

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def is?(role)
    roles.include?(role.to_s)
  end

  protected
  def password_required?
    false
  end

  def email_required?
    false
  end
end
