class UsersController < ApplicationController
  before_action :authenticate_request!, except: [:create, :update, :show]

  def index
    authorize!
    scope = authorized_scope(User.all)
    users = UserResource.all(params, scope)
    respond_with(users)
  end

  def show
    user = UserResource.find(params)
    authorize! user.data
    respond_with(user)
  end

  def create
    authorize!
    user = UserResource.build(params)

    if user.save
      render jsonapi: user, status: 201
    elsif existing_user = user_if_onboarding(user, params)
      render jsonapi: existing_user, status: 201
    else
      render jsonapi_errors: user
    end
  end

  def update
    user = UserResource.find(params)
    authorize! user.data

    if user.update_attributes
      render jsonapi: user
    else
      render jsonapi_errors: user
    end
  end

  def destroy
    user = UserResource.find(params)
    authorize! user.data

    if user.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: user
    end
  end

  private

  def user_if_onboarding(user, params)
    # this might be an onboarding user
    # return unless user.errors.to_a == ["Email has already been taken", "Phone number has already been taken"]
    existing_user = User.find_by(email: user.data.email)
    if existing_user&.is_currently_onboarding?
      UserResource.find(params)
    else
      false
    end
  end
end
