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

    if is_requesting_account_setup? # trying to email account setup
      user = account_setup_user_resource
    elsif is_requesting_service? # not servicing their area
      user = create_interested_user
    else
      user = create_user_resource
    end

    if user.errors.empty?
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

  private

  def create_user_resource
    user = UserResource.build(params)
    user.save
    user
  end

  def user_resource
    @user_resource ||= begin
      email = params.dig(:data, :attributes, :email)
      user = User.find_by!(email: email) if email.present?
      resource = UserResource.find(id: user.id)
      if resource.data.is_currently_onboarding?
        Rails.logger.warn("User #{user.id} is currently onboarding. Skipping.")
        UserResource.build({})
      else
        resource
      end
    rescue => e
      Rails.logger.warn("Failed to find user: #{e.message}")
      UserResource.build({})
    end
  end

  def account_setup_user_resource
    onboarding_step = params.dig(:data, :attributes, :onboarding_step)
    if onboarding_step == OnboardingStep::ACCOUNT_SETUP && user_resource&.data&.needs_setup?
      Users::SendSetupEmailJob.perform_later(user_resource)
    end
    user_resource
  end

  def is_requesting_account_setup?
    params.dig(:data, :attributes, :onboarding_step) == OnboardingStep::ACCOUNT_SETUP
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
