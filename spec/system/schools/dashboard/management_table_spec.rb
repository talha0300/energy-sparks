require 'rails_helper'

RSpec.shared_examples "summary table" do
  let(:management_data) {
    Tables::SummaryTableData.new({ electricity: { year: { :percent_change => 0.11050 }, workweek: { :percent_change => -0.0923132131 } } })
  }

  before(:each) do
    allow_any_instance_of(Schools::ManagementTableService).to receive(:management_data).and_return(management_data)
  end

  context 'and school is data-enabled' do
    before(:each) do
      visit school_path(test_school, switch: true)
    end

    it 'displays summary of recent usage' do
      expect(page).to have_content("Summary of recent energy usage")
    end
  end

  context 'and school is not data-enabled' do
    before(:each) do
      test_school.update!(data_enabled: false)
      visit school_path(test_school, switch: true)
    end

    it 'does not display summary of recent usage' do
      expect(page).to_not have_content("Summary of recent energy usage")
    end
  end
end

RSpec.describe "adult dashboard summary table", type: :system do
  let(:school)             { create(:school) }

  before(:each) do
    sign_in(user) if user.present?
  end

  context 'as guest' do
    let(:user)                { nil }
    include_examples "summary table" do
      let(:test_school) { school }
    end
  end

  context 'as pupil' do
    let(:user)          { create(:pupil, school: school) }
    include_examples "summary table" do
      let(:test_school) { school }
    end
  end

  context 'as staff' do
    let(:user)   { create(:staff, school: school) }
    include_examples "summary table" do
      let(:test_school) { school }
    end
  end

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }
    include_examples "summary table" do
      let(:test_school) { school }
    end
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group) }
    let(:user)          { create(:group_admin, school_group: school_group) }
    include_examples "summary table" do
      let(:test_school) { school }
    end
  end

  context 'as admin' do
    let(:user)        { create(:admin) }

    let(:management_data) {
      Tables::SummaryTableData.new({ electricity: { year: { :percent_change => 0.11050 }, workweek: { :percent_change => -0.0923132131 } } })
    }

    before(:each) do
      allow_any_instance_of(Schools::ManagementTableService).to receive(:management_data).and_return(management_data)
    end

    context 'and school is not data-enabled' do
      before(:each) do
        school.update!(data_enabled: false)
        visit school_path(school)
      end
      it 'overrides flag and shows data-enabled features' do
        expect(page).to have_content("Summary of recent energy usage")
      end
    end
  end
end
