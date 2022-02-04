class AddressesController < ApplicationController
  def index
    addresses = AddressResource.all(params)
    respond_with(addresses)
  end

  def show
    address = AddressResource.find(params)
    respond_with(address)
  end

  def create
    address = AddressResource.build(params)

    if address.save
      render jsonapi: address, status: 201
    else
      render jsonapi_errors: address
    end
  end

  def update
    address = AddressResource.find(params)

    if address.update_attributes
      render jsonapi: address
    else
      render jsonapi_errors: address
    end
  end

  def destroy
    address = AddressResource.find(params)

    if address.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: address
    end
  end
end
