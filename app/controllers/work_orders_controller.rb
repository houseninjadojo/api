class WorkOrdersController < ApplicationController
  def index
    work_orders = WorkOrderResource.all(params)
    respond_with(work_orders)
  end

  def show
    work_order = WorkOrderResource.find(params)
    respond_with(work_order)
  end

  def create
    work_order = WorkOrderResource.build(params)

    if work_order.save
      render jsonapi: work_order, status: 201
    else
      render jsonapi_errors: work_order
    end
  end

  def update
    work_order = WorkOrderResource.find(params)

    if work_order.update_attributes
      render jsonapi: work_order
    else
      render jsonapi_errors: work_order
    end
  end

  def destroy
    work_order = WorkOrderResource.find(params)

    if work_order.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: work_order
    end
  end
end
