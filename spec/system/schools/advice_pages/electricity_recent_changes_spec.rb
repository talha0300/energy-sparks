require 'rails_helper'

RSpec.describe "electricity recent changes advice page", type: :system do
  let(:key) { 'electricity_recent_changes' }
  let(:expected_page_title) { "Electricity recent changes analysis" }
  include_context "electricity advice page"

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }

    before do
      sign_in(user)
      visit school_advice_electricity_recent_changes_path(school)
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }
      it_behaves_like "an advice page tab", tab: "Insights"
    end

    context "clicking the 'Analysis' tab" do

      before do
        click_on 'Analysis'
      end

      it_behaves_like "an advice page tab", tab: "Analysis"

      it "shows titles" do
        expect(page).to have_content("Comparison of electricity use over 2 recent weeks")
        expect(page).to have_content("Comparison of electricity use over 2 recent days")
      end

      it "shows start and end dates" do
        expected_start_date = start_date.to_s(:es_full)
        expected_end_date = end_date.to_s(:es_full)
        expect(page).to have_content("Electricity data is available from #{expected_start_date} to #{expected_end_date}")
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
