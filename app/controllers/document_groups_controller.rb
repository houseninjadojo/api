class DocumentGroupsController < ApplicationController
  before_action do
    if Rails.env.development?
      ActiveStorage::Current.host = request.base_url
    end
  end

  def index
    authorize!
    scope = authorized_scope(DocumentGroup.all)
    document_groups = DocumentGroupResource.all(params, scope)
    respond_with(document_groups)
  end

  def show
    document_group = DocumentGroupResource.find(params)
    authorize! document_group.data
    respond_with(document_group)
  end

  def create
    authorize!
    document_group = DocumentGroupResource.build(params)

    if document_group.save
      render jsonapi: document_group, status: 201
    else
      render jsonapi_errors: document_group
    end
  end

  def update
    document_group = DocumentGroupResource.find(params)
    authorize! document_group.data

    if document_group.update_attributes
      render jsonapi: document_group
    else
      render jsonapi_errors: document_group
    end
  end

  def destroy
    document_group = DocumentGroupResource.find(params)
    authorize! document_group.data

    if document_group.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: document_group
    end
  end
end
