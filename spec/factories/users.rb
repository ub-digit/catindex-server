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

    after :create do |user, evaluator|
      user.generate_token
    end
  end

  factory :access_token do |n|
    association :user, factory: :user
    token SecureRandom.hex
    token_expire Time.now+1.day
  end
end
