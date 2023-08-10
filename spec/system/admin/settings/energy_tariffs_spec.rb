require 'rails_helper'

describe 'site settings energy tariffs', type: :system do
  let!(:school) { create_active_school(name: "Big School")}

  around do |example|
    ClimateControl.modify FEATURE_FLAG_USE_NEW_ENERGY_TARIFFS: 'true' do
      example.run
    end
  end

  context 'as an admin user' do
    let!(:current_user) { create(:admin) }
    before(:each) { sign_in(current_user) }

    context 'allows access to the admin site settings energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/admin/settings/energy_tariffs")
      end

      it_behaves_like "the site settings energy tariff forms well navigated"
    end
  end

  context 'as an analytics user' do
    let!(:current_user) { create(:admin) }
    before(:each) { sign_in(current_user) }

    context 'allows access to the admin site settings energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/admin/settings/energy_tariffs")
      end

      it_behaves_like "the site settings energy tariff forms well navigated"
    end
  end

  context 'as a group_admin user' do
    let!(:current_user) { create(:group_admin) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/users/sign_in")
      end
    end
  end

  context 'as a guest user' do
    let!(:current_user) { create(:guest) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/users/sign_in")
      end
    end
  end

  context 'as a pupil user' do
    let!(:current_user) { create(:pupil, school: school) }
    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/pupils/schools/#{school.slug}")
      end
    end
  end

  context 'as a school admin user' do
    let!(:current_user) { create(:school_admin, school: school) }
    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'as a school_onboarding user' do
    let!(:current_user) { create(:onboarding_user, school: school) }
    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'as a staff user' do
    let!(:current_user) { create(:staff, school: school) }
    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'as a volunteer user' do
    let!(:current_user) { create(:volunteer, school: school) }
    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'with no signed in user' do
    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the sign in page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq('/users/sign_in')
      end
    end
  end
end
