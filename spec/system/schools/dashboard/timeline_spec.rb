require 'rails_helper'

RSpec.shared_examples "dashboard timeline" do
  before(:each) do
    intervention_type = create(:intervention_type, name: 'Upgraded insulation')
    create(:observation, :intervention, school: test_school, intervention_type: intervention_type)
    create(:observation_with_temperature_recording_and_location, school: test_school)
    activity_type = create(:activity_type) # doesn't get saved if built with activity below
    create(:activity, school: test_school, activity_type: activity_type)
    #will automatically add observation
    create(:school_target, school: test_school, start_date: Date.today)
    visit school_path(test_school, switch: true)
  end

  it 'displays events in a timeline' do
    expect(page).to have_content('Recorded temperatures in')
    expect(page).to have_content('Upgraded insulation')
    expect(page).to have_content('Completed an activity')
    expect(page).to have_content('Started working towards an energy saving target')
    click_on 'View all events'
    expect(page).to have_content('Recorded temperatures in')
    expect(page).to have_content('Upgraded insulation')
    expect(page).to have_content('Completed an activity')
    expect(page).to have_content('Started working towards an energy saving target')
  end
end

RSpec.describe "adult dashboard timeline", type: :system do
  let(:regional_calendar)  { create(:regional_calendar) }
  let(:calendar)           { create(:school_calendar, based_on: regional_calendar) }
  let(:school)             { create(:school, calendar: calendar) }

  before(:each) do
    sign_in(user) if user.present?
  end

  context 'as guest' do
    let(:user)                { nil }
    include_examples "dashboard timeline" do
      let(:test_school) { school }
    end
  end

  context 'as pupil' do
    let(:user)          { create(:pupil, school: school) }
    include_examples "dashboard timeline" do
      let(:test_school) { school }
    end
  end

  context 'as staff' do
    let(:user)   { create(:staff, school: school) }
    include_examples "dashboard timeline" do
      let(:test_school) { school }
    end
  end

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }
    include_examples "dashboard timeline" do
      let(:test_school) { school }
    end
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group, calendar: calendar) }
    let(:user)          { create(:group_admin, school_group: school_group) }
    include_examples "dashboard timeline" do
      let(:test_school) { school }
    end
  end
end
