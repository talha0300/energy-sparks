require 'rails_helper'

describe 'school energy tariffs', type: :system do

  around do |example|
    ClimateControl.modify FEATURE_FLAG_NEW_ENERGY_TARIFF_EDITOR: 'true' do
      example.run
    end
  end

  describe 'when creating tariffs' do
    include_context "a school with meters"

    context 'as an admin user' do
      let!(:current_user) { create(:admin) }
      include_examples "a school tariff editor"
    end

    context 'as a school admin user' do
      let!(:current_user) { create(:school_admin, school: school) }
      include_examples "a school tariff editor"
    end

    context 'as a group_admin user' do
      let!(:current_user) { create(:group_admin) }

      context 'does not allow access to the energy tariffs page' do
        it 'redirects to the school index page' do
          visit school_energy_tariffs_path(school)
          expect(current_path).to eq("/users/sign_in")
        end
      end
    end

    context 'as a guest user' do
      let!(:current_user) { create(:guest) }
      let(:path)          { school_energy_tariffs_path(school) }
      before(:each)       { sign_in(current_user) }
      include_examples "the user does not have access to the tariff editor"
    end

    context 'as a pupil user' do
      let!(:current_user) { create(:pupil, school: school) }
      before(:each)       { sign_in(current_user) }
      let(:path)          { school_energy_tariffs_path(school) }
      include_examples "the user does not have access to the tariff editor"
    end

    context 'as a school_onboarding user' do
      let!(:current_user) { create(:onboarding_user, school: school) }
      let(:path)          { school_energy_tariffs_path(school) }
      before(:each)       { sign_in(current_user) }
      include_examples "the user does not have access to the tariff editor"
    end

    context 'as a staff user' do
      let!(:current_user) { create(:staff, school: school) }
      let(:path)          { school_energy_tariffs_path(school) }
      before(:each)       { sign_in(current_user) }
      include_examples "the user does not have access to the tariff editor"
    end

    context 'as a volunteer user' do
      let!(:current_user) { create(:volunteer, school: school) }
      let(:path)          { school_energy_tariffs_path(school) }
      before(:each)       { sign_in(current_user) }
      include_examples "the user does not have access to the tariff editor"
    end

    context 'as a non school user' do
      let!(:school_2)     { create_active_school() }
      let!(:current_user) { create(:user, school: school_2) }
      let(:path)          { school_energy_tariffs_path(school) }
      before(:each)       { sign_in(current_user) }
      include_examples "the user does not have access to the tariff editor"
    end

    context 'as a non school admin user' do
      let!(:school_2)     { create_active_school() }
      let!(:current_user) { create(:school_admin, school: school_2) }
      let(:path)          { school_energy_tariffs_path(school) }
      before(:each)       { sign_in(current_user) }
      include_examples "the user does not have access to the tariff editor"
    end

    context 'with no signed in user' do
      let!(:current_user) { nil }
      let(:path)          { school_energy_tariffs_path(school) }
      include_examples "the user does not have access to the tariff editor"
    end

  end
end
