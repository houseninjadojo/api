class PaymentsController < ApplicationController
  def index
    authorize!
    scope = authorized_scope(Payment.all)
    payments = PaymentResource.all(params, scope)
    respond_with(payments)
  end

  def show
    payment = PaymentResource.find(params)
    authorize! payment.data
    respond_with(payment)
  end

  def create
    authorize!
    payment = PaymentResource.build(params)

    if payment.save
      payment.data.charge_payment_method!(now: true)
      render jsonapi: payment, status: 201
    else
      render jsonapi_errors: payment
    end
  end

  def update
    payment = PaymentResource.find(params)
    authorize! payment.data

    if payment.update_attributes
      render jsonapi: payment
    else
      render jsonapi_errors: payment
    end
  end

  def destroy
    payment = PaymentResource.find(params)
    authorize! payment.data

    if payment.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: payment
    end
  end
end
