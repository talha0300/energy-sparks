# frozen_string_literal: true

class DatePickerFormComponent < ViewComponent::Base
  attr_reader :form_object_name, :field_name, :value

  def initialize(form:, field_name:, value: nil)
    @form_object_name = form.object_name
    @field_name = field_name
    @value = value || DateTime.now.strftime('%d/%m/%Y')
  end

  def id
    "#{form_object_name}_#{field_name}"
  end

  def name
    "#{form_object_name}[#{field_name}]"
  end

  def datetime_picker_id
    "datepickerformcomponent_#{field_name}"
  end
end
