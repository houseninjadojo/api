class PromoCodesController < ApplicationController
  before_action :authenticate_request!, except: [:index, :show]

  def index
    authorize!
    scope = authorized_scope(PromoCode.all)
    # rudimentary security
    # only filter if we know the code
    if params.dig(:filter, :code)
      promo_codes = PromoCodeResource.all(params)
    else
      promo_codes = PromoCodeResource.all({ filter: { id: nil } })
    end
    respond_with(promo_codes)
  end

  def show
    promo_code = PromoCodeResource.find(params)
    authorize! promo_code.data
    respond_with(promo_code)
  end

  def create
    authorize!
    promo_code = PromoCodeResource.build(params)

    if promo_code.save
      render jsonapi: promo_code, status: 201
    else
      render jsonapi_errors: promo_code
    end
  end

  def update
    promo_code = PromoCodeResource.find(params)
    authorize! promo_code.data

    if promo_code.update_attributes
      render jsonapi: promo_code
    else
      render jsonapi_errors: promo_code
    end
  end

  def destroy
    promo_code = PromoCodeResource.find(params)
    authorize! promo_code.data

    if promo_code.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: promo_code
    end
  end
end
