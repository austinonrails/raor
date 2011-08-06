class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  attr_accessible :email, :password, :password_confirmation, :api_key, :name, :remember_me, :roles

  has_many :user_tokens

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
end
