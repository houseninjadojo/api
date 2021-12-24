class PropertiesController < ApplicationController
  def index
    properties = PropertyResource.all(params)
    respond_with(properties)
  end

  def show
    property = PropertyResource.find(params)
    respond_with(property)
  end

  def create
    property = PropertyResource.build(params)

    if property.save
      render jsonapi: property, status: 201
    else
      render jsonapi_errors: property
    end
  end

  def update
    property = PropertyResource.find(params)

    if property.update_attributes
      render jsonapi: property
    else
      render jsonapi_errors: property
    end
  end

  def destroy
    property = PropertyResource.find(params)

    if property.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: property
    end
  end
end
