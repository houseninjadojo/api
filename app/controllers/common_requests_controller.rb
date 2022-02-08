class CommonRequestsController < ApplicationController
  def index
    common_requests = CommonRequestResource.all(params)
    authorized_scope(common_requests)
    respond_with(common_requests)
  end

  def show
    common_request = CommonRequestResource.find(params)
    authorize! common_request
    respond_with(common_request)
  end

  def create
    common_request = CommonRequestResource.build(params)
    authorize! common_request

    if common_request.save
      render jsonapi: common_request, status: 201
    else
      render jsonapi_errors: common_request
    end
  end

  def update
    common_request = CommonRequestResource.find(params)
    authorize! common_request

    if common_request.update_attributes
      render jsonapi: common_request
    else
      render jsonapi_errors: common_request
    end
  end

  def destroy
    common_request = CommonRequestResource.find(params)
    authorize! common_request

    if common_request.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: common_request
    end
  end
end
