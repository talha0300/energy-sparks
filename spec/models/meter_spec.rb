require 'rails_helper'

describe 'Meter', :meters do
  describe 'meter attributes' do
    let(:meter) { build(:electricity_meter) }

    it 'is not pseudo by default' do
      expect(meter.pseudo).to be false
    end

  end

  describe 'valid?' do
    describe 'mpan_mprn' do
      context 'with an electricity meter' do

        let(:attributes) {attributes_for(:electricity_meter)}

        it 'is valid with a 13 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is valid with a 15 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 991098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a 16 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 9991098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

      end

      context 'with a pseudo solar electricity meter' do

        let(:attributes) {attributes_for(:electricity_meter).merge(pseudo: true)}

        it 'is valid with a 14 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 91098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is valid with non-standard 13 digit part' do
          meter = Meter.new(attributes.merge(mpan_mprn: 90000000000037))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 14 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1234))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

        it 'is invalid with a 14 digit number not beginning with 6,7,9' do
          meter = Meter.new(attributes.merge(mpan_mprn: 11098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end
      end

      context 'with a solar pv meter' do

        let(:attributes) {attributes_for(:solar_pv_meter)}

        it 'is valid with a 14 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 12345678901234))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is valid with a 15 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123456789012345))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123456789012))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

        it 'is invalid with a number more than 15 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1234567890123456))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

      end

      context 'with an exported solar pv meter' do

        let(:attributes) {attributes_for(:exported_solar_pv_meter)}

        it 'is valid with a 14 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 61098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123456789012))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

      end

      context 'with a gas meter' do
        let(:attributes) {attributes_for(:gas_meter)}

        it 'is valid with a 10 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1098598765))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number longer than 15 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1234567890123456))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

      end
    end
  end

  describe 'correct_mpan_check_digit?' do
    it 'returns true if the check digit matches' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015001169)
      expect(meter.correct_mpan_check_digit?).to eq(true)
    end

    it 'returns true if the check digit matches ignoring prepended digit for electricity meters' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 92040015001169)
      expect(meter.correct_mpan_check_digit?).to eq(true)
    end

    it 'returns true if the check digit matches ignoring 2 prepended digits for electricity meters' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 992040015001169)
      expect(meter.correct_mpan_check_digit?).to eq(true)
    end

    it 'returns false if the check digit does not match' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015001165)
      expect(meter.correct_mpan_check_digit?).to eq(false)
    end

    it 'returns false if the mpan is short' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015165)
      expect(meter.correct_mpan_check_digit?).to eq(false)
    end
  end

  context 'with amr validated readings' do

    let(:meter) { create(:electricity_meter) }

    context 'with dates' do

      let(:base_date) { Date.today - 1.years }

      before do
        create(:amr_validated_reading, meter: meter, reading_date: base_date)
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 2.days)
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 4.days)
      end

      describe '#last_validated_reading' do
        it "should find latest reading" do
          expect(meter.last_validated_reading).to eql(base_date + 4.days)
        end
      end

      describe '#first_validated_reading' do
        it "should find first reading" do
          expect(meter.first_validated_reading).to eql(base_date)
        end
      end
    end

    context 'with statuses' do

      let(:base_date) { Date.today - 2.years }

      before do
        create(:amr_validated_reading, meter: meter, reading_date: base_date - 2.day, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date - 1.day, status: 'ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date, status: 'ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 1.day, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 2.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 3.days, status: 'ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 4.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 5.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 6.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 7.days, status: 'ORIG')
      end

      describe '#modified_validated_readings' do
        it "should find only non-ORIG readings in last 2 years" do
          expect(meter.modified_validated_readings.count).to eq(5)
        end
      end

      describe '#gappy_validated_readings' do
        it "should find gap in ORIG readings" do
          gaps = meter.gappy_validated_readings(2)
          expect(gaps.count).to eql(2)
          gap = gaps.first
          expect(gap.first.reading_date).to eql(base_date + 1.days)
          expect(gap.last.reading_date).to eql(base_date + 2.days)
          gap = gaps.last
          expect(gap.first.reading_date).to eql(base_date + 4.days)
          expect(gap.last.reading_date).to eql(base_date + 6.days)
        end
      end
    end
  end
end
