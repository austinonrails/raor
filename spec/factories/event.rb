FactoryGirl.define do
  factory :event do
    sequence :name do |n|
      "Event#{n}"
    end

    sequence :description do |n|
      "EventDescription#{n}"
    end

    start_date { Date.today }
    start_time { Time.now }
    end_date { 1.hour.from_now }
    end_time { 1.hour.from_now }

    association :creator, factory: :admin
  end
end