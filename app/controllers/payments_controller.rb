class PaymentsController < ApplicationController
  def index
    payments = PaymentResource.all(params)
    respond_with(payments)
  end

  def show
    payment = PaymentResource.find(params)
    respond_with(payment)
  end

  def create
    payment = PaymentResource.build(params)

    if payment.save
      render jsonapi: payment, status: 201
    else
      render jsonapi_errors: payment
    end
  end

  def update
    payment = PaymentResource.find(params)

    if payment.update_attributes
      render jsonapi: payment
    else
      render jsonapi_errors: payment
    end
  end

  def destroy
    payment = PaymentResource.find(params)

    if payment.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: payment
    end
  end
end
