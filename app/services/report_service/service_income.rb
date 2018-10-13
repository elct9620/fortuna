# frozen_string_literal: true
module ReportService
  class ServiceIncome
    include Callable

    attr_reader :year

    def initialize(year)
      @year = year.to_i
    end

    def call
      generate_report
    end

    private

    def generate_report
      income_data.map do |row|
        {
          employee: format_employee(row[1][0]),
          income: format_as_cells(row[1]),
        }
      end
    end

    def income_data
      Report.service_income(year).ordered.group_by(&:employee_id)
    end

    def format_employee(data)
      {
        id: data.employee_id,
        name: data.name,
        id_number: data.id_number,
        address: data.residence_address,
      }
    end

    def format_as_cells(data)
      cells = []
      12.times do |month|
        if month.zero?
          cells << data.select { |cell| cell.month == 12 and cell.year == year - 1 }.first
        else
          cells << data.select { |cell| cell.month == month }.first
        end
      end
      cells
    end
  end
end
