class PropertiesController < ApplicationController
  before_action :authenticate_request!, except: [:create]

  def index
    authorize!
    scope = authorized_scope(Property.all)
    properties = PropertyResource.all(params, scope)
    respond_with(properties)
  end

  def show
    property = PropertyResource.find(params)
    authorize! property.data
    respond_with(property)
  end

  def create
    authorize!
    property = PropertyResource.build(params)

    if property.save
      render jsonapi: property, status: 201
    else
      render jsonapi_errors: property
    end
  end

  def update
    property = PropertyResource.find(params)
    authorize! property.data

    if property.update_attributes
      render jsonapi: property
    else
      render jsonapi_errors: property
    end
  end

  def destroy
    property = PropertyResource.find(params)
    authorize! property.data

    if property.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: property
    end
  end
end
