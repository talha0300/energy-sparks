require 'rails_helper'

describe NextActivitySuggesterWithKeyStages do

  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }
  let!(:school) { create :school, active: true, key_stages: [ks1, ks3] }

  context "with no activity types set for the school nor any initial suggestions rely on top up" do
    let!(:activity_types_for_ks1_ks2) { create_list(:activity_type, 3, key_stages: [ks1, ks2])}
    let!(:activity_types_for_ks2)     { create_list(:activity_type, 3, key_stages: [ks2])}
    let!(:activity_types_for_ks3)     { create_list(:activity_type, 2, key_stages: [ks1, ks2])}

    let(:no_activity_types_set_or_inital_expected) { activity_types_for_ks1_ks2 + activity_types_for_ks3 }

    subject { NextActivitySuggesterWithKeyStages.new(school) }
    it "suggests any 5 if no suggestions" do
      expect(subject.suggest).to match_array(no_activity_types_set_or_inital_expected)
    end
  end

  context "with initial suggestions" do

    let!(:activity_types_with_suggestions_for_ks1_ks2) { create_list(:activity_type, 3, :as_initial_suggestions, key_stages: [ks1, ks2])}
    let!(:activity_types_with_suggestions_for_ks2)     { create_list(:activity_type, 3, :as_initial_suggestions, key_stages: [ks2])}
    let!(:activity_types_with_suggestions_for_ks3)     { create_list(:activity_type, 2, :as_initial_suggestions, key_stages: [ks1, ks2])}

    let(:activity_types_with_suggestions) { activity_types_with_suggestions_for_ks1_ks2 + activity_types_with_suggestions_for_ks3 }

    subject { NextActivitySuggesterWithKeyStages.new(school) }
    it "suggests the first five initial suggestions" do
     expect(subject.suggest).to match_array(activity_types_with_suggestions)
    end
  end

  context "with suggestions based on last activity type" do

    let!(:activity_type_with_further_suggestions)   { create :activity_type, :with_further_suggestions, number_of_suggestions: 6, key_stages: [ks1, ks3]}
    let!(:last_activity) { create :activity, school: school, activity_type: activity_type_with_further_suggestions }

    subject { NextActivitySuggesterWithKeyStages.new(school) }

    it "suggests the five follow ons from original" do
      ks2_this_one = activity_type_with_further_suggestions.suggested_types.third
      ks2_this_one.update(key_stages: [ks2], name: 'DROP ME')

      result = subject.suggest
      expected = activity_type_with_further_suggestions.suggested_types.reject {|ats| ats.id == ks2_this_one.id }

      expect(result).to match_array(expected)
    end
  end

  context "with suggestions based on last activity type" do

    let!(:activity_type_with_further_suggestions)   { create :activity_type, :with_further_suggestions, number_of_suggestions: 6, key_stages: [ks1, ks3]}
    let!(:last_activity) { create :activity, school: school, activity_type: activity_type_with_further_suggestions }

    subject { NextActivitySuggesterWithKeyStages.new(school) }

    it "suggests the five follow ons from original" do
      repeatable_done = activity_type_with_further_suggestions.suggested_types.second
      activity = create(:activity, activity_type: repeatable_done, school: school)

      non_repeatable_done = activity_type_with_further_suggestions.suggested_types.third
      non_repeatable_done.update( name: 'DROP ME', repeatable: false)
      activity = create(:activity, activity_type: non_repeatable_done, school: school)

      result = subject.suggest
      activity_type_with_further_suggestions.reload
      expected = activity_type_with_further_suggestions.suggested_types.reject {|ats| ats.id == non_repeatable_done.id }

      expect(result).to match_array(expected)
    end
  end
end
