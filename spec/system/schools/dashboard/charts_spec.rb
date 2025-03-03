require 'rails_helper'

RSpec.shared_examples "dashboard chart display" do
  let(:dashboard_charts) { [] }

  before(:each) do
    test_school.configuration.update!(dashboard_charts: dashboard_charts)
    visit school_path(test_school, switch: true)
  end

  context 'and all charts can be shown' do
    before(:each) do
      visit school_path(test_school, switch: true)
    end
    let(:dashboard_charts) { [:management_dashboard_group_by_week_electricity, :management_dashboard_group_by_week_gas, :management_dashboard_group_by_week_storage_heater, :management_dashboard_group_by_month_solar_pv] }
    it 'displays the expected charts' do
      expect(page).to have_content("Recent energy usage")
      expect(page).to have_css("#management-energy-overview")
      expect(page).to have_css("#electricity-overview")
      expect(page).to have_css("#gas-overview")
      expect(page).to have_css("#storage_heater-overview")
      expect(page).to have_css("#solar-overview")
    end
  end

  context 'and there are limited charts' do
    before(:each) do
      visit school_path(test_school, switch: true)
    end
    let(:dashboard_charts) { [:management_dashboard_group_by_week_electricity, :management_dashboard_group_by_week_gas] }
    it 'displays the expected charts' do
      expect(page).to have_content("Recent energy usage")
      expect(page).to have_css("#management-energy-overview")
      expect(page).to have_css("#electricity-overview")
      expect(page).to have_css("#gas-overview")
      expect(page).to_not have_css("#storage_heater-overview")
      expect(page).to_not have_css("#solar-overview")
    end
  end

  context 'and there are no charts to display' do
    before(:each) do
      visit school_path(test_school, switch: true)
    end

    it 'displays the expected charts' do
      expect(page).to_not have_content("Recent energy usage")
      expect(page).to_not have_css("#management-energy-overview")
    end
  end
end

RSpec.describe "adult dashboard charts", type: :system do
  let(:school)             { create(:school) }

  before(:each) do
    sign_in(user) if user.present?
  end

  context 'as guest' do
    let(:user)                { nil }
    include_examples "dashboard chart display" do
      let(:test_school) { school }
    end
  end

  context 'as pupil' do
    let(:user)          { create(:pupil, school: school) }
    include_examples "dashboard chart display" do
      let(:test_school) { school }
    end
    context 'and school is not data-enabled' do
      before(:each) do
        school.update!(data_enabled: false)
        visit school_path(school, switch: true)
      end
      it 'shows placeholder chart' do
        expect(page).to have_css(".chart-placeholder-image")
      end
    end
  end

  context 'as staff' do
    let(:user)   { create(:staff, school: school) }
    include_examples "dashboard chart display" do
      let(:test_school) { school }
    end
    context 'and school is not data-enabled' do
      before(:each) do
        school.update!(data_enabled: false)
        visit school_path(school)
      end
      it 'shows placeholder chart' do
        expect(page).to have_css(".chart-placeholder-image")
      end
    end
  end

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }
    include_examples "dashboard chart display" do
      let(:test_school) { school }
    end
    context 'and school is not data-enabled' do
      before(:each) do
        school.update!(data_enabled: false)
        visit school_path(school)
      end
      it 'shows placeholder chart' do
        expect(page).to have_css(".chart-placeholder-image")
      end
    end
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group) }
    let(:user)          { create(:group_admin, school_group: school_group) }
    include_examples "dashboard chart display" do
      let(:test_school) { school }
    end
    context 'and school is not data-enabled' do
      before(:each) do
        school.update!(data_enabled: false)
        visit school_path(school)
      end
      it 'shows placeholder chart' do
        expect(page).to have_css(".chart-placeholder-image")
      end
    end
  end
end
