class DocumentsController < ApplicationController
  def index
    documents = DocumentResource.all(params)
    respond_with(documents)
  end

  def show
    document = DocumentResource.find(params)
    respond_with(document)
  end

  def create
    document = DocumentResource.build(params)

    if document.save
      render jsonapi: document, status: 201
    else
      render jsonapi_errors: document
    end
  end

  def update
    document = DocumentResource.find(params)

    if document.update_attributes
      render jsonapi: document
    else
      render jsonapi_errors: document
    end
  end

  def destroy
    document = DocumentResource.find(params)

    if document.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: document
    end
  end
end
