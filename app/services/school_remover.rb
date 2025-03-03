class SchoolRemover
  class Error < StandardError; end

  def initialize(school, archive: false)
    @school = school
    @archive = archive
  end

  def school_ready?
    !@school.visible?
  end

  def meters_ready?
    @school.meters.active.empty?
  end

  def users_ready?
    @school.users.all?(&:access_locked?)
  end

  def can_remove_school?
    meters_ready? && users_ready? && school_ready?
  end

  def remove_school!
    raise SchoolRemover::Error.new('Cannot remove school while it is still visible') if @school.visible?
    @school.transaction do
      if @school.update!(active: false, process_data: false, removal_date: removal_date)
        delete_school_issues
      end
    end
  end

  def reenable_school!
    raise SchoolRemover::Error.new('Cannot reenable an active school') if @school.active?
    @school.transaction do
      @school.update(active: true, removal_date: nil)
    end
  end

  def remove_users!
    raise SchoolRemover::Error.new('Cannot remove users while school is still visible') if @school.visible?
    @school.transaction do
      @school.users.each do |user|
        if user.has_other_schools?
          user.remove_school(@school)
        else
          user.contacts.for_school(@school).first&.destroy unless @archive
          user.lock_access!(send_instructions: false)
        end
      end
    end
  end

  def remove_meters!
    raise SchoolRemover::Error.new('Cannot remove meters while school is still visible') if @school.visible?
    @school.transaction do
      @school.meters.each do |meter|
        remove_meter(meter)
      end
    end
  end

  private

  def delete_school_issues
    return if @archive

    IssueMeter.where(meter: @school.meters).delete_all
    @school.issues.delete_all
  end

  def removal_date
    @archive ? nil : Time.zone.today
  end

  def remove_meter(meter)
    service = MeterManagement.new(meter)
    service.deactivate_meter!
    service.remove_data!(archive: @archive)
  end
end
