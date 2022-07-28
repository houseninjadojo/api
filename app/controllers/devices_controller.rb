class DevicesController < ApplicationController
  before_action :authenticate_request!, except: [:create, :update, :index]

  def index
    authorize!
    scope = authorized_scope(Device.all)
    # rudimentary security
    # only filter if we know the device_id
    if params.dig(:filter, :device_id)
      devices = DeviceResource.all(params)
    else
      # search for nothing
      devices = DeviceResource.all(params, scope)
    end
    respond_with(devices)
  end

  def show
    device = DeviceResource.find(params)
    authorize! device.data
    respond_with(device)
  end

  def create
    authorize!
    device = DeviceResource.build(params)
    if device.save
      render jsonapi: device, status: 201
    else
      render jsonapi_errors: device
    end
  end

  def update
    device = DeviceResource.find(params)
    if allowed_to?(:update?, device.data)
      if device.update_attributes
        render jsonapi: device
      else
        render jsonapi_errors: device
      end
    else
      render jsonapi: { meta: {} }, status: 200
    end
  end

  def destroy
    device = DeviceResource.find(params)
    authorize! device.data

    if device.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: device
    end
  end
end
