class DocumentsController < ApplicationController
  before_action do
    if Rails.env.development?
      ActiveStorage::Current.host = request.base_url
    end
  end

  def index
    authorize!
    scope = authorized_scope(Document.for_vault)
    documents = DocumentResource.all(params, scope)
    respond_with(documents)
  end

  def show
    document = DocumentResource.find(params)
    authorize! document.data
    respond_with(document)
  end

  def create
    authorize!
    document = DocumentResource.build(params)

    if document.save
      render jsonapi: document, status: 201
    else
      render jsonapi_errors: document
    end
  end

  def update
    document = DocumentResource.find(params)
    authorize! document.data

    if document.update_attributes
      render jsonapi: document
    else
      render jsonapi_errors: document
    end
  end

  def destroy
    document = DocumentResource.find(params)
    authorize! document.data

    if document.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: document
    end
  end
end
