class UsersController < ApplicationController
  before_action :authenticate_request!, except: [:create, :update, :show]

  def index
    users = UserResource.all(params)
    authorized_scope(users, with: UserPolicy, context: { user: current_user})
    respond_with(users)
  end

  def show
    user = UserResource.find(params)
    authorize!(user, to: :show?, with: UserPolicy, context: { user: current_user })
    respond_with(user)
  end

  def create
    user = UserResource.build(params)
    authorize!(user, to: :create?, with: UserPolicy, context: { user: current_user })

    if user.save
      render jsonapi: user, status: 201
    else
      render jsonapi_errors: user
    end
  end

  def update
    user = UserResource.find(params)
    authorize!(user, to: :update?, with: UserPolicy, context: { user: current_user })

    if user.update_attributes
      render jsonapi: user
    else
      render jsonapi_errors: user
    end
  end

  def destroy
    user = UserResource.find(params)
    authorize!(user, to: :destroy?, with: UserPolicy, context: { user: current_user })

    if user.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: user
    end
  end
end
