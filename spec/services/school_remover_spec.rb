require 'rails_helper'

describe SchoolRemover, :schools, type: :service do

  let(:school)              { create(:school, visible: false) }
  let!(:school_admin)       { create(:school_admin, school: school) }
  let!(:contact)            { create(:contact_with_name_email_phone, school: school, user: school_admin)}

  let!(:electricity_meter) { create(:electricity_meter_with_validated_reading, school: school) }
  let!(:gas_meter)         { create(:gas_meter, :with_unvalidated_readings, school: school)}
  let!(:electricity_meter_issue)             { create(:issue, school: school) }
  let!(:gas_meter_issue)             { create(:issue, school: school) }
  let!(:school_issue)             { create(:issue, school: school) }


  let(:archive) { false }
  let(:service) { SchoolRemover.new(school, archive: archive) }

  before do
    electricity_meter_issue.meters << electricity_meter
    electricity_meter_issue.save!
    gas_meter_issue.meters << gas_meter
    gas_meter_issue.save!
  end

  describe '#remove_school!' do
    it 'marks the school as inactive, sets removal date and deletes any school meter or school issues' do
      service.remove_school!
      expect(school.active).to be_falsey
      expect(school.process_data).to be_falsey
      expect(school.removal_date).to eq(Time.zone.today)
      expect(electricity_meter.issues.count).to eq 0
      expect(gas_meter.issues.count).to eq 0
      expect(school.issues.count).to eq 0
    end

    it 'fails if school is visible' do
      school.update(visible: true)
      expect {
        service.remove_school!
      }.to raise_error(SchoolRemover::Error)
    end

    context 'when archive flag set true' do
      let(:archive) { true }
      it 'marks the school as inactive but with no removal date or issue deletion' do
        service.remove_school!
        expect(school.active).to be_falsey
        expect(school.process_data).to be_falsey
        expect(school.removal_date).to be_nil
        expect(electricity_meter.issues.count).to eq 1
        expect(gas_meter.issues.count).to eq 1
        expect(school.issues.count).to eq 3
      end
    end
  end

  describe '#remove_users!' do
    let(:remove)    { service.remove_users! }
    it 'locks the user accounts' do
      remove
      expect(school.users.all?(&:access_locked?)).to be_truthy
    end

    it 'removes alert contacts' do
      remove
      expect(Contact.count).to eq 0
    end

    context 'when archiving' do
      let(:archive) { true }
      it 'keeps the alert contacts' do
        remove
        expect(Contact.count).to eq 1
      end
    end
    context 'when user is linked to other schools' do
      let(:other_school)  { create(:school) }
      before do
        school_admin.add_cluster_school(other_school)
        remove
      end
      it 'does not lock user and switches them to the other school' do
        school_admin.reload
        expect(school_admin.access_locked?).to be_falsey
        expect(school_admin.school).to eq(other_school)
      end
    end

    context
  end

  describe '#remove_meters!' do
    before(:each) do
      service.remove_meters!
    end

    it 'deactivates the meters' do
      electricity_meter.reload
      expect(electricity_meter.active).to eq false
      gas_meter.reload
      expect(gas_meter.active).to eq false
    end

    it 'removes the validated data' do
      expect(AmrValidatedReading.count).to eq 0
    end

    it 'dissociates the unvalidated data' do
      expect(AmrDataFeedReading.first.meter).to be_nil
    end

    context 'when archive flag is set' do
      let(:archive) { true }

      it 'removes the validated data' do
        expect(AmrValidatedReading.count).to eq 0
      end
      it 'does not unlink the unvalidated data' do
        expect(AmrDataFeedReading.first.meter).to_not be_nil
      end
    end
  end

  # remove onboarding?
  # remove calendars?

end
