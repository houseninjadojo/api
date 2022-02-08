class SubscriptionsController < ApplicationController
  before_action :authenticate_request!, except: [:create]

  def index
    authorize!
    scope = Subscription.all
    subscriptions = SubscriptionResource.all(params, scope)
    respond_with(subscriptions)
  end

  def show
    subscription = SubscriptionResource.find(params)
    authorize! subscription.data
    respond_with(subscription)
  end

  def create
    authorize!
    subscription = SubscriptionResource.build(params)

    if subscription.save
      render jsonapi: subscription, status: 201
    else
      render jsonapi_errors: subscription
    end
  end

  def update
    subscription = SubscriptionResource.find(params)
    authorize! subscription.data

    if subscription.update_attributes
      render jsonapi: subscription
    else
      render jsonapi_errors: subscription
    end
  end

  def destroy
    subscription = SubscriptionResource.find(params)
    authorize! subscription.data

    if subscription.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: subscription
    end
  end
end
