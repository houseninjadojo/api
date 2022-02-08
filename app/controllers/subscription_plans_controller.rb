class SubscriptionPlansController < ApplicationController
  before_action :authenticate_request!, except: [:index, :show]

  def index
    authorize!
    scope = authorized_scope(SubscriptionPlan.all)
    subscription_plans = SubscriptionPlanResource.all(params)
    respond_with(subscription_plans)
  end

  def show
    subscription_plan = SubscriptionPlanResource.find(params)
    authorize! subscription_plan.data
    respond_with(subscription_plan)
  end

  def create
    authorize!
    subscription_plan = SubscriptionPlanResource.build(params)

    if subscription_plan.save
      render jsonapi: subscription_plan, status: 201
    else
      render jsonapi_errors: subscription_plan
    end
  end

  def update
    subscription_plan = SubscriptionPlanResource.find(params)
    authorize! subscription_plan.data

    if subscription_plan.update_attributes
      render jsonapi: subscription_plan
    else
      render jsonapi_errors: subscription_plan
    end
  end

  def destroy
    subscription_plan = SubscriptionPlanResource.find(params)
    authorize! subscription_plan.data

    if subscription_plan.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: subscription_plan
    end
  end
end
