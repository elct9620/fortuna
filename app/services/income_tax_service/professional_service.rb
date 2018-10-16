# frozen_string_literal: true
module IncomeTaxService
  class ProfessionalService
    include Callable
    include Calculatable

    attr_reader :payroll

    def initialize(payroll)
      @payroll = payroll
    end

    # 執行業務所得超過兩萬元 需代扣 10% 所得稅
    def call
      return 0 unless taxable?
      (income_before_withholdings * rate).round
    end

    private

    def taxable?
      income_before_withholdings > exemption
    end

    def exemption
      20000
    end

    def rate
      0.1
    end
  end
end
