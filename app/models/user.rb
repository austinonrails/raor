class User < ActiveRecord::Base
  ROLES = %w[admin moderator author banned]
  
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  attr_accessible :name, :email, :password, :password_confirmation, :api_key, :name, :remember_me, :roles, :user, :uid, :provider,
                  :user_tokens_attributes, :as => :default
  attr_accessible :id, :email, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at,
                  :current_sign_in_ip,:last_sign_in_ip,:name,:created_at,:updated_at, :user_tokens_attributes, :as => :admin

  has_many :user_tokens
  has_many :checkins
  has_many :events, :through => :checkins

  accepts_nested_attributes_for :user_tokens

  def self.find_for_twitter_oauth(omniauth, signed_in_resource=nil)
    authentication = UserToken.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication && authentication.user
      authentication.user
    else
      User.new
      # In a typical app you would create a new user here:
      # User.create!(:email => data['email'], :password => Devise.friendly_token[0,20]) 
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
end
