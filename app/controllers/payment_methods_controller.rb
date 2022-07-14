class PaymentMethodsController < ApplicationController
  before_action :authenticate_request!, except: [:create]

  def index
    authorize!
    scope = authorized_scope(PaymentMethod.active)
    payment_methods = PaymentMethodResource.all(params, scope)
    respond_with(payment_methods)
  end

  def show
    payment_method = PaymentMethodResource.find(params)
    authorize! payment_method.data
    respond_with(payment_method)
  end

  def create
    authorize!
    payment_method = PaymentMethodResource.build(params)

    if payment_method.save
      payment_method.data.sync_create!
      render jsonapi: payment_method, status: 201
    else
      render jsonapi_errors: payment_method
    end
  end

  def update
    payment_method = PaymentMethodResource.find(params)
    authorize! payment_method.data

    if payment_method.update_attributes
      render jsonapi: payment_method
    else
      render jsonapi_errors: payment_method
    end
  end

  def destroy
    payment_method = PaymentMethodResource.find(params)
    authorize! payment_method.data

    if payment_method.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: payment_method
    end
  end
end
