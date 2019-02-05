FactoryBot.define do
  factory :school do
    sequence(:urn)
    sequence(:name) { |n| "test #{n} school" }
    school_type :primary
    active true
    address { '1 Station Road' }
    postcode 'ab1 2cd'
    website { "http://#{name.camelize}.test" }
    sash

    factory :school_with_same_name do
      name { "test school"}
    end

    trait :with_school_group do
      after(:create) do |school, evaluator|
        school.update(school_group: create(:school_group))
      end
    end

    trait :with_calendar do
      after(:create) do |school, evaluator|
        school.update(calendar: create(:calendar))
      end
    end

    trait :with_badges do
      transient do
        badges_sashes 1
      end

      after(:build) do |school, evaluator|
        create(:badge) do |badge|
          create_list :badges_sash, evaluator.badges_sashes, badge_id: badge.id, sash_id: school.sash_id
        end
      end
    end

    trait :with_points do
      transient do
        score_points 1
      end

      after(:build) do |school, evaluator|
        create(:score, sash_id: school.sash_id) do |score|
          create_list :score_point, evaluator.score_points, score_id: score.id
        end
      end
    end
  end
end
