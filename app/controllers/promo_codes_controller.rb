class PromoCodesController < ApplicationController
  before_action :authenticate_request!, except: [:index, :show]

  def index
    promo_codes = PromoCodeResource.all(params)
    respond_with(promo_codes)
  end

  def show
    promo_code = PromoCodeResource.find(params)
    respond_with(promo_code)
  end

  def create
    promo_code = PromoCodeResource.build(params)

    if promo_code.save
      render jsonapi: promo_code, status: 201
    else
      render jsonapi_errors: promo_code
    end
  end

  def update
    promo_code = PromoCodeResource.find(params)

    if promo_code.update_attributes
      render jsonapi: promo_code
    else
      render jsonapi_errors: promo_code
    end
  end

  def destroy
    promo_code = PromoCodeResource.find(params)

    if promo_code.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: promo_code
    end
  end
end
