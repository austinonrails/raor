FactoryGirl.define do
  factory :admin, class: User do
    sequence :name do |n|
      "Admin#{n}"
    end

    sequence :email do |n|
      "admin#{n}@example.com"
    end

    sequence :password do |n|
      "Password#{n}"
    end

    roles ["admin"]
  end
end