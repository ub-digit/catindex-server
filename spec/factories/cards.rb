FactoryGirl.define do


  factory :card, class: Card do

    trait :not_started do
      primary_registrator_start nil
    end

    trait :primary_started do
      primary_registrator_start Time.now
    end

    trait :primary_ended do
      primary_registrator_end Time.now
    end

    trait :secondary_started do
      secondary_registrator_start Time.now
    end

    trait :secondary_ended do
      secondary_registrator_end Time.now
    end

    trait :tertiary_started do
      tertiary_registrator_start Time.now
    end

    trait :tertiary_ended do
      tertiary_registrator_end Time.now
    end

    trait :primary_problem do
      primary_registrator_problem 'asdf'
    end

    trait :secondary_problem do
      secondary_registrator_problem 'asdf'
    end

    trait :tertiary_problem do
      tertiary_registrator_problem 'asdf'
    end

    factory :not_started_card, traits: [:not_started]
    factory :primary_started_card, traits: [:primary_started]
    factory :primary_ended_card, traits: [:primary_started, :primary_ended]
    factory :primary_problem_card, traits: [:primary_started, :primary_ended, :primary_problem]
    factory :secondary_started_card, traits: [:primary_started, :primary_ended, :secondary_started]
    factory :secondary_ended_card, traits: [:primary_started, :primary_ended, :secondary_started, :secondary_ended]
    factory :secondary_problem_card, traits: [:primary_started, :primary_ended, :secondary_started, :secondary_ended, :secondary_problem]
    factory :tertiary_started_card, traits: [:primary_started, :primary_ended, :secondary_started, :secondary_ended, :tertiary_started]
    factory :tertiary_ended_card, traits: [:primary_started, :primary_ended, :secondary_started, :secondary_ended, :tertiary_started, :tertiary_ended]
    factory :tertiary_problem_card, traits: [
      :primary_started, :primary_ended, :secondary_started, :secondary_ended,
      :tertiary_started, :tertiary_ended, :tertiary_problem
    ]
  end
end
