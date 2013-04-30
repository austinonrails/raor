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
    end_date { (start_date.is_a?(String) ? Date.parse(start_date) : start_date) + 1.hour }
    end_time { (start_time.is_a?(String) ? Time.parse(start_time) : start_time) + 1.hour }

    association :creator, factory: :admin
  end
end