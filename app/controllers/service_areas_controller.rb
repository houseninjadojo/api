class ServiceAreasController < ApplicationController
  before_action :authenticate_request!, except: [:index, :show]

  def index
    authorize!
    scope = authorized_scope(ServiceArea.all)
    # rudimentary security
    # only filter if we know the code
    if params.dig(:filter, :zipcodes)
      service_areas = ServiceAreaResource.all(params)
    else
      service_areas = ServiceAreaResource.all({ filter: { id: nil } })
    end
    respond_with(service_areas)
  end

  def show
    service_area = ServiceAreaResource.find(params)
    authorize! service_area.data
    respond_with(service_area)
  end

  def create
    authorize!
    service_area = ServiceAreaResource.build(params)

    if service_area.save
      render jsonapi: service_area, status: 201
    else
      render jsonapi_errors: service_area
    end
  end

  def update
    service_area = ServiceAreaResource.find(params)
    authorize! service_area.data

    if service_area.update_attributes
      render jsonapi: service_area
    else
      render jsonapi_errors: service_area
    end
  end

  def destroy
    service_area = ServiceAreaResource.find(params)
    authorize! service_area.data

    if service_area.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: service_area
    end
  end
end
