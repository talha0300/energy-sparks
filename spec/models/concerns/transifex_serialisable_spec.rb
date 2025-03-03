require 'rails_helper'

describe TransifexSerialisable do

  class Dummy
    include TransifexSerialisable
  end

  context 'when converting rich text' do

    let(:test) { Dummy.new }

    describe '#mustache_to_yaml' do
      it 'converts chart tags' do
        expect(test.mustache_to_yaml('text {{#chart}}some_chart{{/chart}} here')).to eq('text %{tx_chart_some_chart} here')
      end
      it 'converts simple variable tags' do
        expect(test.mustache_to_yaml('text {{position}} here')).to eq('text %{tx_var_position} here')
      end
      it 'converts multiple simple variable tags' do
        expect(test.mustache_to_yaml('text {{position}} {{count}} here')).to eq('text %{tx_var_position} %{tx_var_count} here')
      end
      it 'converts combinations of tags' do
        expect(test.mustache_to_yaml('text {{#chart}}some_chart{{/chart}} at {{position}} here')).to eq('text %{tx_chart_some_chart} at %{tx_var_position} here')
      end
      it 'handles odd chars in chart names' do
        expect(test.mustache_to_yaml('text {{#chart}}some_chart|£{{/chart}} here')).to eq('text %{tx_chart_some_chart|£} here')
      end
    end

    describe '#yaml_template_to_mustache' do
      it 'converts original chart tags' do
        expect(test.yaml_template_to_mustache('text %{some_chart} here')).to eq('text {{#chart}}some_chart{{/chart}} here')
      end
      it 'converts new chart tags' do
        expect(test.yaml_template_to_mustache('text %{tx_chart_some_chart} here')).to eq('text {{#chart}}some_chart{{/chart}} here')
      end
      it 'converts simple variable tags' do
        expect(test.yaml_template_to_mustache('text %{tx_var_position} here')).to eq('text {{position}} here')
      end
      it 'converts multiple simple variable tags' do
        expect(test.yaml_template_to_mustache('text %{tx_var_position} %{tx_var_count} here')).to eq('text {{position}} {{count}} here')
      end
      it 'converts combinations of tags' do
        expect(test.yaml_template_to_mustache('text %{tx_chart_some_chart} and %{other_chart} at %{tx_var_position} here')).to eq('text {{#chart}}some_chart{{/chart}} and {{#chart}}other_chart{{/chart}} at {{position}} here')
      end
      it 'handles odd chars in chart names' do
        expect(test.yaml_template_to_mustache('text %{tx_chart_some_chart|£} here')).to eq('text {{#chart}}some_chart|£{{/chart}} here')
      end
    end
  end

  context 'with real classes' do

    before do
      #we have to explicitly require the classes otherwise they're not loaded and
      #check for included modules fails
      Dir[Rails.root.join("app/models/**/*.rb")].each { |f| require f }
      @tx_serialisables = ApplicationRecord.descendants.select { |c| c.included_modules.include? TransifexSerialisable }
    end

    it 'all including models have timestamps and include Mobility' do
      @tx_serialisables.each do |clazz|
        expect(clazz.column_names).to include("created_at", "updated_at"), "expected #{clazz.name} to have timestamps"
        expect(clazz.singleton_class.ancestors).to include(Mobility), "expected #{clazz.name} to extend Mobility"
      end
    end

    it 'model shows no content present if no attributes set' do
      serialisable = @tx_serialisables.first.new
      expect(serialisable.has_content?).to be_falsey
    end

    it 'model shows content present if some attribute set' do
      clazz = @tx_serialisables.first
      attr = clazz.mobility_attributes.first
      serialisable = clazz.new(attr => 'something')
      expect(serialisable.has_content?).to be_truthy
    end
  end
end
