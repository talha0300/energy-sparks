require 'rails_helper'

describe 'TransportSurvey' do

  context "with valid attributes" do
    subject { create :transport_survey }
    it { is_expected.to be_valid }
  end

  describe "#responses=" do
    subject { create :transport_survey }

    describe "adding a response" do
      let(:attributes) { attributes_for(:transport_survey_response, surveyed_at: surveyed_at, run_identifier: run_identifier) }
      let(:surveyed_at) { DateTime.new(2021,03,18,9,0,0) }
      let(:run_identifier) { 1234 }

      before(:each) { subject.responses = [attributes] }
      it { expect(subject.responses.length).to eql 1 }

      describe "adding another response" do
        let(:new_attributes) { attributes_for(:transport_survey_response, surveyed_at: new_surveyed_at, run_identifier: new_run_identifier) }
        before(:each) { subject.responses = [new_attributes] }

        context "with the same run_identifier" do
          let(:new_run_identifier) { run_identifier }

          context "and the same surveyed_at time" do
            let(:new_surveyed_at) { surveyed_at }
            it { expect(subject.responses.length).to eql 1 }
          end

          context "and different surveyed_at time" do
            let(:new_surveyed_at) { DateTime.new(2022,03,18,9,0,0) }
            it { expect(subject.responses.length).to eql 2 }
          end
        end

        context "with a different run_identifier" do
          let(:new_run_identifier) { 9999 }

          context "and the same surveyed_at time" do
            let(:new_surveyed_at) { surveyed_at }
            it { expect(subject.responses.length).to eql 2 }
          end

          context "and a different surveyed_at time" do
            let(:new_surveyed_at) { DateTime.new(2022,03,18,9,0,0) }
            it { expect(subject.responses.length).to eql 2 }
          end
        end
      end
    end
  end

  describe "#total_responses" do
    subject { create :transport_survey }
    context "with no responses" do
      it { expect(subject.total_responses).to eql 0 }
    end

    context "with one response" do
      before(:each) do
        create :transport_survey_response, transport_survey: subject, passengers: 2
      end
      it { expect(subject.total_responses).to eql 1 }
    end
    context "with more than one response" do
      before(:each) do
        create :transport_survey_response, transport_survey: subject, passengers: 2
        create :transport_survey_response, transport_survey: subject, passengers: 3
      end
      it { expect(subject.total_responses).to eql 2 }
    end
  end

  describe "#total_carbon" do
    subject { create :transport_survey }

    context "with no responses" do
      it { expect(subject.total_carbon).to eql 0 }
    end

    context "with one response" do
      let!(:response) { create(:transport_survey_response, transport_survey: subject, passengers: 2) }
      it { expect(subject.total_carbon).to eql response.carbon }
    end

    context "with more than one response" do
      let!(:responses) do
        [ create(:transport_survey_response, transport_survey: subject, passengers: 2),
          create(:transport_survey_response, transport_survey: subject, passengers: 3) ]
      end

      it "adds up the carbon for each response" do
        expect(subject.total_carbon).to eql(responses[0].carbon + responses[1].carbon)
      end
    end
  end

  describe "Category based methods" do
    subject { create :transport_survey }

    let(:categories) { TransportType.categories.keys << nil }

    def create_responses(cats)
      cats.each do |cat|
        transport_type = create(:transport_type, category: cat)
        create(:transport_survey_response, transport_survey: subject, transport_type: transport_type, passengers: 3)
      end
    end

    describe "#responses_per_category" do
      context "when there are responses in each category" do
        before(:each) { create_responses(categories) }

        it "returns a hash of responses per category" do
          expect(subject.responses_per_category).to eql( {"car" => 1, "active_travel" => 1, "public_transport" => 1, "park_and_stride" => 1, "other" => 1} )
        end
      end

      context "when not all categories have responses" do
        before { create_responses(categories.excluding('car', 'active_travel')) }

        it "returns a hash with zero values for missing categories" do
          expect(subject.responses_per_category).to eql( {"car" => 0, "active_travel" => 0, "public_transport" => 1, "park_and_stride" => 1, "other" => 1} )
        end

        context "and categories have multiple responses" do
          before { create_responses(categories) }
          it "adds them up" do
            expect(subject.responses_per_category).to eql( {"car" => 1, "active_travel" => 1, "public_transport" => 2, "park_and_stride" => 2, "other" => 2} )
          end
        end
      end

      context "when there are no responses" do
        it "returns a hash with zero values for missing categories" do
          expect(subject.responses_per_category).to eql( {"car" => 0, "active_travel" => 0, "public_transport" => 0, "park_and_stride" => 0, "other" => 0} )
        end
      end
    end

    describe "#percentage_per_category" do
      context "when there are responses in each category" do
        before { create_responses(categories) }

        it "returns a hash of responses percentages per category" do
          expect(subject.percentage_per_category).to eql( {"car" => 20.0, "active_travel" => 20.0, "public_transport" => 20.0, "park_and_stride" => 20.0, "other" => 20.0} )
        end
      end

      context "when not all categories have responses" do
        before { create_responses(categories.excluding('car', 'park_and_stride', nil)) }
        it "returns zero values for missing categories" do
          expect(subject.percentage_per_category).to eql( {"car" => 0, "active_travel" => 50.0, "public_transport" => 50.0 , "park_and_stride" => 0, "other" => 0 } )
        end

        context "and categories have multiple responses" do
          before { create_responses(categories) }
          it "adds them up" do
            expect(subject.percentage_per_category).to eql( {"car" => 14.285714285714285, "active_travel" => 28.57142857142857, "public_transport" => 28.57142857142857, "park_and_stride" => 14.285714285714285, "other" => 14.285714285714285} )
          end
        end
      end

      context "when there are no responses" do
        it "returns zero values for missing categories" do
          expect(subject.percentage_per_category).to eql( {"car" => 0, "active_travel" => 0, "public_transport" => 0, "park_and_stride" => 0, "other" => 0 } )
        end
      end
    end

    describe "#pie_chart_data" do
      context "when there are passengers in each category" do
        before { create_responses(categories) }

        it "returns passenger percentages per category" do
          expect(subject.pie_chart_data).to eql( [{name: "Active travel", y: 20.0}, {name: "Car", y: 20.0}, {name: "Public transport", y: 20.0}, {name: "Park and stride", y: 20.0}, {name: "Other", y: 20.0}] )
        end
      end

      context "when not all categories have passengers" do
        before { create_responses(categories.excluding('car', 'park_and_stride', nil)) }

        it "returns zero values for missing categories" do
          expect(subject.pie_chart_data).to eql( [{name: "Active travel", y: 50.0}, {name: "Car", y: 0}, {name: "Public transport", y: 50.0}, {name: "Park and stride", y: 0}, {name: "Other", y: 0}] )
        end
      end

      context "when there are no responses" do
        it "returns zero values for missing categories" do
          expect(subject.pie_chart_data).to eql( [{name: "Active travel", y: 0}, {name: "Car", y: 0}, {name: "Public transport", y: 0}, {name: "Park and stride", y: 0}, {name: "Other", y: 0}] )
        end
      end
    end
  end

  describe "#today?" do
    context "when survey has a run_on date of today" do
      subject { create :transport_survey, run_on: Time.zone.today }
      it { expect(subject.today?).to be true }
    end

    context "when survey has a run_on date other than today" do
      subject { create :transport_survey, run_on: 3.days.ago }
      it { expect(subject.today?).to be false }
    end
  end

end
