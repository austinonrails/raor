FactoryGirl.define do
  factory :banned, class: User do
    sequence :name do |n|
      "Banned#{n}"
    end

    sequence :email do |n|
      "banned#{n}@example.com"
    end

    sequence :password do |n|
      "Password#{n}"
    end

    roles ["banned"]
  end
end