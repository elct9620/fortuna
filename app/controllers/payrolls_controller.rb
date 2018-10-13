# frozen_string_literal: true
class PayrollsController < ApplicationController
  before_action :prepare_payroll, only: [:edit, :update, :destroy]
  before_action :store_location, only: [:index]

  def index
    @q = Payroll.search_result.ransack(params[:q])
    @payrolls = @q.result(distinct: true).page(params[:page])
  end

  def init
    PayrollsInitService.call(params[:year], params[:month])
    redirect_to_date(params[:year], params[:month])
  end

  def edit
  end

  def update
    if @payroll.update(payroll_params)
      StatementSyncService.call(@payroll)
      redirect_to session.delete(:return_to)
    else
      render :edit
    end
  end

  def destroy
  end

  private

  def payroll_params
    params.require(:payroll).permit(
      :parttime_hours, :leavetime_hours, :sicktime_hours,
      :vacation_refund_hours, :festival_bonus, :festival_type,
      overtimes_attributes: [:date, :rate, :hours, :_destroy, :id],
      extra_entries_attributes: [:title, :amount, :taxable, :note, :_destroy, :id]
    )
  end

  def prepare_payroll
    @payroll = Payroll.find_by(id: params[:id]) or not_found
  end

  def redirect_to_date(year, month)
    redirect_to action: :index, q: { year_eq: year, month_eq: month }
  end
end
