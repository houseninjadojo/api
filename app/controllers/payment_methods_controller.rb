class PaymentMethodsController < ApplicationController
  def index
    payment_methods = PaymentMethodResource.all(params)
    respond_with(payment_methods)
  end

  def show
    payment_method = PaymentMethodResource.find(params)
    respond_with(payment_method)
  end

  def create
    payment_method = PaymentMethodResource.build(params)

    if payment_method.save
      render jsonapi: payment_method, status: 201
    else
      render jsonapi_errors: payment_method
    end
  end

  def update
    payment_method = PaymentMethodResource.find(params)

    if payment_method.update_attributes
      render jsonapi: payment_method
    else
      render jsonapi_errors: payment_method
    end
  end

  def destroy
    payment_method = PaymentMethodResource.find(params)

    if payment_method.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: payment_method
    end
  end
end
