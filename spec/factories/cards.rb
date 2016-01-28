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

    factory :not_started_card, traits: [:not_started]
    factory :primary_started_card, traits: [:primary_started]
    factory :primary_ended_card, traits: [:primary_started, :primary_ended]
    factory :secondary_started_card, traits: [:primary_started, :primary_ended, :secondary_started]
    factory :secondary_ended_card, traits: [:primary_started, :primary_ended, :secondary_started, :secondary_ended]
  end
end
