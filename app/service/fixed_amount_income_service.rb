# frozen_string_literal: true
class FixedAmountIncomeService
  attr_reader :payroll, :salary

  def initialize(payroll, salary)
    @payroll = payroll
    @salary = salary
  end

  def run
    {
      overtime_meals: overtime_meal_subsidy,
      business_trip: business_trip_subsidy,
      vacation_refund: vacation_refund,
      overtime: overtime,
    }.transform_values(&:to_i)
  end

  private

  def overtime
    payroll.overtimes.map { |i| OvertimeService.new(i.hours, salary).send(i.rate) }.reduce(:+)
  end

  def vacation_refund
    OvertimeService.new(payroll.vacation_refund_hours, salary).basic
  end

  def overtime_meal_subsidy
    payroll.overtime_meals * overtime_meal_rate
  end

  def business_trip_subsidy
    payroll.business_trip_days * business_trip_rate
  end

  def overtime_meal_rate
    120
  end

  def business_trip_rate
    1000
  end
end
