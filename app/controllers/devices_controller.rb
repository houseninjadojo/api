class DevicesController < ApplicationController
  before_action :authenticate_request!, except: [:create, :update]

  def index
    devices = DeviceResource.all(params)
    respond_with(devices)
  end

  def show
    device = DeviceResource.find(params)
    respond_with(device)
  end

  def create
    device = DeviceResource.find(params)

    # new device
    if !device.errors.empty?
      device = DeviceResource.build(params)
      if device.save
        render jsonapi: device, status: 201
      else
        render jsonapi_errors: device
      end
      return
    end
    # / new device

    if device.update_attributes
      render jsonapi: device, status: 201
    else
      render jsonapi_errors: device
    end
  end

  def update
    device = DeviceResource.find(params)

    if device.update_attributes
      render jsonapi: device
    else
      render jsonapi_errors: device
    end
  end

  def destroy
    device = DeviceResource.find(params)

    if device.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: device
    end
  end
end
