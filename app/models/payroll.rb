# frozen_string_literal: true
class Payroll < ApplicationRecord
  belongs_to :employee
  has_many :overtimes, dependent: :destroy
  has_many :bonuses, dependent: :destroy
end
