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

    current_user { user }
  end
end