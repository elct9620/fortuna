# frozen_string_literal: true
require "test_helper"

# FIXME: needs to refactor and remove start/end date
class EmployeeTest < ActiveSupport::TestCase
  def test_has_least_one_salary_record
    assert_operator emp.salaries.length, :>, 0
  end

  def test_has_payrolls_until_next_month
    assert_equal emp.payrolls.length, months_until_now
  end

  def test_has_all_payrolls_with_same_salary
    assert_equal emp.payrolls.map(&:salary).size, emp.payrolls.length
  end

  def test_has_same_amount_between_payrolls_and_statements
    emp.payrolls.each { |payroll| StatementService::Builder.call(payroll) }
    assert_equal emp.payrolls.length, emp.statements.length
  end

  def test_find_salary
    employee = build(:employee)
    create(:term, start_date: "2015-05-13", end_date: "2016-11-15", employee: employee)
    create(:term, start_date: "2018-02-06", end_date: nil, employee: employee)
    salary1 = create(:salary, effective_date: "2015-05-13", employee: employee)
    salary2 = create(:salary, effective_date: "2015-09-01", employee: employee)
    salary3 = create(:salary, effective_date: "2018-02-06", employee: employee)

    assert_nil employee.find_salary(Date.new(2015, 4, 1), Date.new(2015, 4, -1))
    assert_equal salary1, employee.find_salary(Date.new(2015, 5, 1), Date.new(2015, 5, -1))
    assert_equal salary2, employee.find_salary(Date.new(2015, 9, 1), Date.new(2015, 9, -1))
    assert_nil employee.find_salary(Date.new(2016, 12, 1), Date.new(2016, 12, -1))
    assert_equal salary3, employee.find_salary(Date.new(2018, 2, 1), Date.new(2018, 2, -1))
  end

  def test_scope_on_payroll_201802
    Timecop.freeze(Date.new(2018, 2, 19)) do
      assert Employee.on_payroll(Date.new(2018, 2, 1), Date.new(2018, 2, -1)).include? john
      assert Employee.on_payroll(Date.new(2018, 2, 1), Date.new(2018, 2, -1)).include? jack
      assert_not Employee.on_payroll(Date.new(2018, 2, 1), Date.new(2018, 2, -1)).include? jane

      assert_not Employee.inactive.include? john
      assert_not Employee.inactive.include? jack
      assert Employee.inactive.include? jane
    end
  end

  def test_scope_on_payroll_201805
    Timecop.freeze(Date.new(2018, 5, 20)) do
      assert Employee.on_payroll(Date.new(2018, 5, 1), Date.new(2018, 5, -1)).include? john
      assert_not Employee.on_payroll(Date.new(2018, 5, 1), Date.new(2018, 5, -1)).include? jack
      assert Employee.on_payroll(Date.new(2018, 5, 1), Date.new(2018, 5, -1)).include? jane

      assert_not Employee.inactive.include? john
      assert Employee.inactive.include? jack
      assert_not Employee.inactive.include? jane
    end
  end

  def test_scope_on_payroll_201812
    Timecop.freeze(Date.new(2018, 12, 3)) do
      assert Employee.on_payroll(Date.new(2018, 12, 1), Date.new(2018, 12, -1)).include? jack
      assert_not Employee.inactive.include? jack
    end
  end

  def test_scope_active
    Timecop.freeze(Date.new(2018, 1, 20)) do
      Employee.expects(:on_payroll).with(Date.new(2018, 1, 1), Date.new(2018, 1, -1)).returns(true)
      assert Employee.active
    end
  end

  def test_email
    Timecop.freeze(Date.new(2018, 2, 19)) do
      assert_equal "jack@5xruby.tw", jack.email
    end

    Timecop.freeze(Date.new(2018, 3, 19)) do
      assert_equal "jack@gmail.com", jack.email
    end

    Timecop.freeze(Date.new(2018, 9, 20)) do
      assert_equal "jack@5xruby.tw", jack.email
    end
  end

  def test_scope_ordered
    5.times { create(:employee) }
    assert Employee.ordered.each_cons(2).all? { |first, second| first.id >= second.id }
  end

  def test_term
    employee = build(:employee)
    term1 = create(:term, start_date: "2017-12-18", end_date: "2018-08-16", employee: employee)
    term2 = create(:term, start_date: "2018-11-12", employee: employee)

    assert_nil employee.term(Date.new(2017, 11, 1), Date.new(2017, 11, -1))
    assert_equal term1, employee.term(Date.new(2017, 12, 1), Date.new(2017, 12, -1))
    assert_equal term1, employee.term(Date.new(2018, 8, 1), Date.new(2018, 8, -1))
    assert_nil employee.term(Date.new(2018, 9, 1), Date.new(2018, 9, -1))
    assert_equal term2, employee.term(Date.new(2018, 11, 1), Date.new(2018, 11, -1))
    assert_equal term2, employee.term(Date.new(2018, 12, 1), Date.new(2018, 12, -1))

    assert_equal term2, employee.recent_term
  end

  private

  def emp
    @emp ||= create(:employee_with_payrolls, month_salary: 50000, build_statement_immediatedly: false)
  end

  def months_until_now
    TimeDifference.between(emp.start_date, Date.today).in_months.round
  end

  def john
    @john ||= create(
      :employee,
      company_email: "john@5xruby.tw",
      personal_email: "john@gmail.com"
    ) { |employee| create(:term, start_date: "2017-01-01", employee: employee) }
  end

  def jack
    @jack ||= create(
      :employee,
      company_email: "jack@5xruby.tw",
      personal_email: "jack@gmail.com"
    ) do |employee| 
      create(:term, start_date: "2017-10-01", end_date: "2018-02-06", employee: employee)
      create(:term, start_date: "2018-09-13", end_date: nil, employee: employee)
    end
  end

  def jane
    @jane ||= create(
      :employee,
      company_email: nil,
      personal_email: "jane@gmail.com"
    ) { |employee| create(:term, start_date: "2018-03-01", employee: employee) }
  end
end
