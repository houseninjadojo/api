class ServiceAreasController < ApplicationController
  before_action :authenticate_request!, except: [:index, :show]

  def index
    service_areas = ServiceAreaResource.all(params)
    respond_with(service_areas)
  end

  def show
    service_area = ServiceAreaResource.find(params)
    respond_with(service_area)
  end

  def create
    service_area = ServiceAreaResource.build(params)

    if service_area.save
      render jsonapi: service_area, status: 201
    else
      render jsonapi_errors: service_area
    end
  end

  def update
    service_area = ServiceAreaResource.find(params)

    if service_area.update_attributes
      render jsonapi: service_area
    else
      render jsonapi_errors: service_area
    end
  end

  def destroy
    service_area = ServiceAreaResource.find(params)

    if service_area.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: service_area
    end
  end
end
