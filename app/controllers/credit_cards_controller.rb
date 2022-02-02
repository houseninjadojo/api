class CreditCardsController < ApplicationController
  def index
    credit_cards = CreditCardResource.all(params)
    respond_with(credit_cards)
  end

  def show
    credit_card = CreditCardResource.find(params)
    respond_with(credit_card)
  end

  def create
    credit_card = CreditCardResource.build(params)

    if credit_card.save
      render jsonapi: credit_card, status: 201
    else
      render jsonapi_errors: credit_card
    end
  end

  def update
    credit_card = CreditCardResource.find(params)

    if credit_card.update_attributes
      render jsonapi: credit_card
    else
      render jsonapi_errors: credit_card
    end
  end

  def destroy
    credit_card = CreditCardResource.find(params)

    if credit_card.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: credit_card
    end
  end
end
