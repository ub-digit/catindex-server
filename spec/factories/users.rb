FactoryGirl.define do

  sequence :username do |n|
    "user_#{n}"
  end

  factory :user, class: User do
    username {generate :username}
    password "secret"
    operator
    
    trait :admin do
      role "ADMIN"
    end

    trait :operator do
      role "OPER"
    end

    factory :admin_user, traits: [:admin]
  end
end
