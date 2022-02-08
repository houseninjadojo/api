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
    user = UserResource.build(params)
    # authorize! user.data

    if user.save
      render jsonapi: user, status: 201
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
end
