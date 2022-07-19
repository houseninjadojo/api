class CreditCardsController < ApplicationController
  # before_action :authenticate_request!, except: [:create, :update]

  def index
    authorize!
    scope = authorized_scope(CreditCard.active)
    credit_cards = CreditCardResource.all(params, scope)
    respond_with(credit_cards)
  end

  def show
    credit_card = CreditCardResource.find(params)
    authorize! credit_card.data
    respond_with(credit_card)
  end

  def create
    authorize!
    credit_card = CreditCardResource.build(params)

    if credit_card.save
      # credit_card.data&.sync_create!
      render jsonapi: credit_card, status: 201
    else
      render jsonapi_errors: credit_card
    end
  end

  def update
    credit_card = CreditCardResource.find(params)
    authorize! credit_card.data

    if credit_card.update_attributes
      render jsonapi: credit_card
    else
      render jsonapi_errors: credit_card
    end
  end

  def destroy
    credit_card = CreditCardResource.find(params)
    authorize! credit_card.data

    if credit_card.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: credit_card
    end
  end
end
