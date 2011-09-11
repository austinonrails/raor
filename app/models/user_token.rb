class UserToken < ActiveRecord::Base
  belongs_to :user

  attr_accessible :user, :user_id, :provider, :uid, :as => :default
  attr_accessible :user, :user_id, :provider, :uid, :created_at, :updated_at, :as => :admin
end
