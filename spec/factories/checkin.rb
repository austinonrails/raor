FactoryGirl.define do
  factory :checkin do
    employ false
    employer ''
    employment false
    rafflr false
    remember_employer false
    shoutout 'Shoutout!'

    association :event
    association :user
    association :current_user, factory: :user
  end
end