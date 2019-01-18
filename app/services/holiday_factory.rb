class HolidayFactory
  def initialize(calendar)
    @calendar = calendar
  end

  def create
    raise ArgumentError unless CalendarEventType.where(holiday: true).any?

    holiday_type = CalendarEventType.holiday.first
    events = @calendar.calendar_events
    terms = events.eager_load(:calendar_event_type).where('calendar_event_types.term_time = true').order(start_date: :asc)

    terms.each_with_index do |term, index|
      next_term = terms[index + 1]
      next if next_term.nil?

      holiday_start_date = term.end_date + 1.day
      holiday_end_date = next_term.start_date - 1.day

      if holiday_end_date >= holiday_start_date
        CalendarEvent.where(calendar: @calendar, calendar_event_type: holiday_type, start_date: holiday_start_date, end_date: holiday_end_date).first_or_create!
      end
    end
  end

  def with_neighbour_updates(calendar_event, attributes)
    calendar_event.transaction do
      pre_save = []
      post_save = []
      calendar_event.attributes = attributes

      if calendar_event.calendar_event_type.term_time || calendar_event.calendar_event_type.holiday
        if calendar_event.start_date_changed?
          update_previous_events(calendar_event, pre_save, post_save)
        end
        if calendar_event.end_date_changed?
          update_following_events(calendar_event, pre_save, post_save)
        end
      end

      pre_save.map(&:call)
      calendar_event.save!
      post_save.map(&:call)
      true
    end
  rescue ActiveRecord::RecordInvalid
    return false
  end

private

  def update_previous_events(calendar_event, pre_save, post_save)
    previous_event = @calendar.terms_and_holidays.find_by(end_date: calendar_event.start_date_was - 1.day)
    if previous_event
      callback = calendar_event.start_date > calendar_event.start_date_was ? post_save : pre_save
      new_event_end = calendar_event.start_date - 1.day
      callback << if new_event_end < previous_event.start_date
                    lambda { previous_event.destroy }
                  else
                    lambda { previous_event.update!(end_date: calendar_event.start_date - 1.day) }
                  end
    end
  end

  def update_following_events(calendar_event, pre_save, post_save)
    following_event = @calendar.terms_and_holidays.find_by(start_date: calendar_event.end_date_was + 1.day)
    if following_event
      callback = calendar_event.end_date > calendar_event.end_date_was ? pre_save : post_save
      new_event_start = calendar_event.end_date + 1.day
      callback << if new_event_start > following_event.end_date
                    lambda { following_event.destroy }
                  else
                    lambda { following_event.update!(start_date: calendar_event.end_date + 1.day) }
                  end
    end
  end
end
