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

    if is_requesting_service?
      user = create_interested_user
      render jsonapi: user, status: 201
      return
    end

    user = UserResource.build(params)

    if user.save
      render jsonapi: user, status: 201
    else
      existing_user = user_if_onboarding(user, params)
      if existing_user.errors.empty?
        render jsonapi: existing_user, status: 201
      else
        render jsonapi_errors: existing_user
      end
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
    @existing_user = User.find_by(email: user.data.email)
    resource = UserResource.find(id: @existing_user.id)
    if !@existing_user.is_currently_onboarding?
      resource.data.errors.add(:base, :account_already_setup, message: "You already have an active account. Please log in to continue.")
    elsif resource.data.needs_setup?
      Users::SendSetupEmailJob.perform_later(@existing_user)
      # resource.data.errors.add(:base, :setup_email_sent, message: "Check your email for further instructions.")
    end
    resource
  end

  def is_requesting_service?
    params.dig(:data, :attributes, :requested_zipcode).present?
  end

  def create_interested_user
    ContactType::SERVICE_AREA_REQUESTED
    email = params.dig(:data, :attributes, :email)
    zip = params.dig(:data, :attributes, :requested_zipcode)
    if email.present? && zip.present?
      Users::CreateIntestedUserJob.perform_later(email: email, zipcode: zip)
    end
    {
      data: {
        type: 'users',
        id: SecureRandom.uuid,
        attributes: {
          email: email,
          requested_zipcode: zip,
        },
      },
    }
  end
end
