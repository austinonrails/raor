FactoryGirl.define do
  factory :moderator, class: User do
    sequence :name do |n|
      "Moderator#{n}"
    end

    sequence :email do |n|
      "moderator#{n}@example.com"
    end

    sequence :password do |n|
      "Password#{n}"
    end

    roles ["moderator"]
  end
end