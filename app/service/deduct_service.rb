# frozen_string_literal: true
class DeductService
  attr_reader :payroll, :salary

  def initialize(payroll, salary)
    @payroll = payroll
    @salary = salary
  end

  def run
    {
      勞保費: labor_insurance,
      健保費: health_insurance,
      請假扣薪: leavetime + sicktime,
    }.merge(extra_loss)
  end

  private

  def labor_insurance
    LaborInsuranceService.new(salary).run
  end

  def health_insurance
    HealthInsuranceService.new(salary).run
  end

  def leavetime
    LeavetimeService.new(payroll.leavetime_hours, salary, payroll.days_in_cycle).normal
  end

  def sicktime
    LeavetimeService.new(payroll.sicktime_hours, salary, payroll.days_in_cycle).sick
  end

  def extra_loss
    ExtraEntriesService.new(payroll).loss
  end
end
