class WorkOrdersController < ApplicationController
  before_action :authenticate_request!, except: [:show]

  def index
    authorize!
    scope = authorized_scope(WorkOrder.all)
    work_orders = WorkOrderResource.all(params, scope)
    respond_with(work_orders)
  end

  def show
    if access_token.present?
      record = begin
        invoice = Invoice.includes(:work_order).find_by(access_token: access_token)
        estimate = Estimate.includes(:work_order).find_by(access_token: access_token)
        invoice || estimate
      end
      params[:id] = record&.work_order&.id
      user = access_token_user
    else
      user = current_user
    end
    work_order = WorkOrderResource.find(params)
    authorize!(work_order.data, context: { user: user })
    respond_with(work_order)
  end

  def create
    authorize!
    work_order = WorkOrderResource.build(params)

    if work_order.save
      render jsonapi: work_order, status: 201
    else
      render jsonapi_errors: work_order
    end
  end

  def update
    work_order = WorkOrderResource.find(params)
    authorize! work_order.data

    if work_order.update_attributes
      render jsonapi: work_order
    else
      render jsonapi_errors: work_order
    end
  end

  def destroy
    work_order = WorkOrderResource.find(params)
    authorize! work_order.data

    if work_order.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: work_order
    end
  end
end
