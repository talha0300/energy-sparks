require 'rails_helper'

RSpec.describe Targets::ProgressService do

  let!(:school)                   { create(:school) }
  let!(:electricity_progress)     { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
  let!(:school_target)            { create(:school_target, school: school, electricity_progress: electricity_progress) }

  let(:fuel_electricity)          { Schools::FuelConfiguration.new(has_electricity: true) }

  let!(:school_config)            { create(:configuration, school: school, fuel_configuration: fuel_electricity) }

  let!(:service)                  { Targets::ProgressService.new(school) }

  context '#progress_summary' do
    it 'returns nil if school has no target' do
      SchoolTarget.all.destroy_all
      expect( service.progress_summary ).to be nil
    end

    context 'with only electricity fuel type' do
      let(:progress_summary) { service.progress_summary }

      it 'includes school target in summary' do
        expect( progress_summary.school_target ).to eql school_target
      end

      it 'includes only that fuel type' do
        expect( progress_summary.gas_progress ).to be nil
        expect( progress_summary.storage_heater_progress ).to be nil
        expect( progress_summary.electricity_progress ).to_not be nil
      end

      it 'reports the fuel progress' do
        expect( progress_summary.electricity_progress.progress ).to eql 0.99
        expect( progress_summary.electricity_progress.usage ).to eql 15
        expect( progress_summary.electricity_progress.target ).to eql 20
      end
    end
  end

  context '#display_progress_for_fuel_type' do
    it 'checks only for fuel type' do
      expect( service.display_progress_for_fuel_type?(:electricity) ).to be true
      expect( service.display_progress_for_fuel_type?(:gas) ).to be false
      expect( service.display_progress_for_fuel_type?(:storage_heaters) ).to be false
    end

  end

end
