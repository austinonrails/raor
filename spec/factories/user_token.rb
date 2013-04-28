FactoryGirl.define do
  factory :user_token do
    provider 'twitter'
    sequence :uid
  end
end