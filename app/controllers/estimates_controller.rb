class EstimatesController < ApplicationController
  before_action :authenticate_request!, except: [:show]

  def index
    authorize!
    scope = authorized_scope(Estimate.all)
    estimates = EstimateResource.all(params, scope)
    respond_with(estimates)
  end

  def show
    # if access token is present, use it to find the estimate
    # as well, bypass authorization context
    # otherwise, use the id as usual
    if unauthed_access_token.present?
      estimate_record = Estimate.find_by(access_token: unauthed_access_token)
      params[:id] = estimate_record.id
      user = unauthed_access_token_user
    else
      user = current_user
    end
    estimate = EstimateResource.find(params)
    authorize!(estimate.data, context: { user: user })
    respond_with(estimate)
  end

  def create
    authorize!
    estimate = EstimateResource.build(params)

    if estimate.save
      render jsonapi: estimate, status: 201
    else
      render jsonapi_errors: estimate
    end
  end

  def update
    # # if access token is present, use it to find the estimate
    # # as well, bypass authorization context
    # # otherwise, use the id as usual
    # if access_token.present?
    #   estimate_record = Estimate.find_by(access_token: access_token)
    #   params[:id] = estimate_record.id
    #   user = access_token_user
    # else
    #   user = current_user
    # end
    estimate = EstimateResource.find(params)
    authorize!(estimate.data, context: { user: current_user })

    if estimate.update_attributes
      render jsonapi: estimate
    else
      render jsonapi_errors: estimate
    end
  end

  def destroy
    estimate = EstimateResource.find(params)
    authorize! estimate.data

    if estimate.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: estimate
    end
  end

  private

  # decrypt and reveal access token, or nil
  # access token is derived from id
  def unauthed_access_token_payload
    @unauthed_access_token_payload ||= begin
      payload = params.fetch(:id, nil)
      EncryptionService.decrypt(payload)&.with_indifferent_access
    rescue => e
      nil
    end
  end

  def unauthed_access_token
    @unauthed_access_token ||= unauthed_access_token_payload&.fetch(:access_token, nil)
  end

  def unauthed_access_token_user
    @unauthed_access_token_user ||= begin
      user_id = unauthed_access_token_payload&.fetch(:user_id, nil)
      User.find_by(id: user_id)
    end
  end
end
