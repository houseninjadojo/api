class EstimatesController < ApplicationController
  def index
    estimates = EstimateResource.all(params)
    respond_with(estimates)
  end

  def show
    estimate = EstimateResource.find(params)
    respond_with(estimate)
  end

  def create
    estimate = EstimateResource.build(params)

    if estimate.save
      render jsonapi: estimate, status: 201
    else
      render jsonapi_errors: estimate
    end
  end

  def update
    estimate = EstimateResource.find(params)

    if estimate.update_attributes
      render jsonapi: estimate
    else
      render jsonapi_errors: estimate
    end
  end

  def destroy
    estimate = EstimateResource.find(params)

    if estimate.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: estimate
    end
  end
end
