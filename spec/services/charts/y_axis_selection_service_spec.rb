require 'rails_helper'

describe Charts::YAxisSelectionService do

  let(:preference)          { :default }
  let(:school)              { create(:school, chart_preference: preference) }
  let(:chart_name)          { :gas_longterm_trend }
  let(:service)             { Charts::YAxisSelectionService.new(school, chart_name) }

  context '#possible_y1_axis_choices' do
    it 'returns some possibilities' do
      expect(Charts::YAxisSelectionService.possible_y1_axis_choices).to_not be_empty
    end
  end

  context '#y1_axis_choices' do
    it 'returns expected choices' do
      expect(service.y1_axis_choices).to eql(%i[kwh £ co2])
    end
  end

  context '#select_y_axis' do
    context 'with no preference' do
      it 'returns nil' do
        expect(service.select_y_axis).to be_nil
      end
    end

    context 'with default preference set' do
      let(:preference)          { :default }
      it 'returns co2' do
        expect(service.select_y_axis).to be_nil
      end
    end

    context 'with carbon preference set' do
      let(:preference)          { :carbon }
      it 'returns co2' do
        expect(service.select_y_axis).to eq :co2
      end
    end

    context 'with usage preference set' do
      let(:preference)          { :usage }
      it 'returns kwh' do
        expect(service.select_y_axis).to eq :kwh
      end
    end

    context 'with cost preference set' do
      let(:preference)          { :cost }
      it 'returns £' do
        expect(service.select_y_axis).to eq :£
      end
    end

    context 'when main option not available' do
      let(:preference)          { :carbon }
      before(:each) do
        allow_any_instance_of(ChartYAxisManipulation).to receive(:y1_axis_choices).and_return(options)
      end

      context 'no co2' do
        let(:options) { [:kwh, :£] }
        it 'returns nil' do
          expect(service.select_y_axis).to be_nil
        end
      end

      context 'only cost' do
        let(:options) { [:£] }
        it 'returns nil' do
          expect(service.select_y_axis).to be_nil
        end
      end

      context 'no options' do
        let(:options) { nil }
        it 'returns nil' do
          expect(service.select_y_axis).to be_nil
        end
      end
    end
  end
end
