# frozen_string_literal: true
module EmployeeDecorator
  def role
    salaries.last.given_role
  end
end
