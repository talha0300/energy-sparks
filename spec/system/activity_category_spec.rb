require 'rails_helper'

RSpec.describe "activity type", type: :system do
  let!(:admin)  { create(:admin)}

  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }

  let!(:unlikely_school) { create(:school, key_stages: [ks1, ks3])}
  let!(:unlikely_school_user) { create(:staff, school: unlikely_school)}

  let!(:activity_category_1) { create(:activity_category, name: 'cat1')}
  let!(:activity_type_1) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks1, ks2])}
  let!(:activity_type_3) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}

  let!(:activity_category_2) { create(:activity_category, name: 'cat2')}
  let!(:activity_type_2) { create(:activity_type, activity_category: activity_category_2, key_stages: [ks3])}


  describe 'activities can be filtered' do
    before(:each) do
      visit activity_categories_path
    end

    it 'by defaults shows cat 1 activity types', js: true do
      expect(page.has_content?(activity_type_1.name)).to be true
      expect(page.has_content?(activity_type_3.name)).to be true
      expect(page.has_content?(activity_type_2.name)).to_not be true
    end

    it 'shows cat 2 activity types if selected', js: true do
      click_on('cat2')
      assert_text(activity_type_2.name)
      expect(page.has_content?(activity_type_1.name)).to_not be true
      expect(page.has_content?(activity_type_2.name)).to be true
    end

    it 'shows cat 2 activity types if selected' do
      expect(page).to have_unchecked_field('KS1')
      expect(page).to have_unchecked_field('KS2')
      expect(page).to have_unchecked_field('KS3') # or have_unchecked_field
      check('KS1')
      click_button('Filter Activity Types', match: :first)
      expect(page).to have_checked_field('KS1')
      expect(page).to have_unchecked_field('KS2')
      expect(page).to have_unchecked_field('KS3') # or have_unchecked_field

      expect(page.has_content?(activity_type_1.name)).to be true
      expect(page.has_content?(activity_type_3.name)).to_not be true
    end
  end
end
