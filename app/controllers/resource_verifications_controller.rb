class ResourceVerificationsController < ApplicationController
  before_action :authenticate_request!, except: [:create]

  def create
    resource_verification = ResourceVerificationResource.build(params)

    if resource_verification.save
      render jsonapi: resource_verification, status: 201
    else
      render jsonapi_errors: resource_verification
    end
  end
end
