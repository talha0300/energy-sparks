require 'rails_helper'

describe AdvicePageHelper do

  let(:school)                    { create(:school) }
  let(:advice_page)               { create(:advice_page, key: 'baseload') }
  let(:advice_page_not_in_routes) { create(:advice_page, key: 'notapage') }

  describe '.advice_baseload_high?' do
    it 'returns true if value higher than 0.0' do
      expect(helper.advice_baseload_high?(0.1)).to be_truthy
    end
    it 'returns false if value less than 0.0' do
      expect(helper.advice_baseload_high?(-0.1)).to be_falsey
    end
    it 'returns false if value equals 0.0' do
      expect(helper.advice_baseload_high?(0.0)).to be_falsey
    end
  end

  describe '.chart_start_month_year' do
    it 'returns month and year' do
      expect(helper.chart_start_month_year(Date.parse('20210101'))).to eq('December 2019')
    end
  end

  describe '.chart_end_month_year' do
    it 'returns month and year' do
      expect(helper.chart_end_month_year(Date.parse('20210101'))).to eq('December 2020')
    end
  end

  describe '.two_weeks_data?' do
    it 'returns true if there are at least 14 days between two dates' do
      expect(helper.two_weeks_data?(start_date: Date.new(2021,01,01), end_date: Date.new(2021,01,15))).to eq(true)
      expect(helper.two_weeks_data?(start_date: Date.new(2021,01,02), end_date: Date.new(2021,01,15))).to eq(false)
    end
  end

  describe '.advice_page_path' do

    it 'returns path to insights by default' do
      expect(helper.advice_page_path(school, advice_page)).to end_with("/schools/#{school.slug}/advice/baseload/insights")
    end

    it 'returns path to insights tab' do
      expect(helper.advice_page_path(school, advice_page, :insights)).to end_with("/schools/#{school.slug}/advice/baseload/insights")
    end

    it 'returns path to analysis tab' do
      expect(helper.advice_page_path(school, advice_page, :analysis)).to end_with("/schools/#{school.slug}/advice/baseload/analysis")
    end

    it 'errors if advice page is not legit' do
      expect {
        helper.advice_page_path(school, advice_page_not_in_routes)
      }.to raise_error(NoMethodError)
    end

    it 'errors if tab is not legit' do
      expect {
        helper.advice_page_path(school, advice_page, :blah)
      }.to raise_error(NoMethodError)
    end

  end

  describe '.sort_by_label' do
    before :each do
      I18n.backend.store_translations("en", {advice_pages: {nav: { pages: { one: "ZZZ", two: "AAA" }}}})
      I18n.backend.store_translations("cy", {advice_pages: {nav: { pages: { one: "AAA", two: "ZZZ" }}}})
    end
    let(:advice_page_1) { create(:advice_page, key: 'one') }
    let(:advice_page_2) { create(:advice_page, key: 'two') }
    let(:advice_pages) { [advice_page_1, advice_page_2] }
    it 'sorts by default label' do
      sorted_advice_pages = helper.sort_by_label(advice_pages)
      expect(sorted_advice_pages.map(&:key)).to eq(["two", "one"])
    end
    it 'sorts by cy label' do
      I18n.with_locale(:cy) do
        sorted_advice_pages = helper.sort_by_label(advice_pages)
        expect(sorted_advice_pages.map(&:key)).to eq(["one", "two"])
      end
    end
  end
end
