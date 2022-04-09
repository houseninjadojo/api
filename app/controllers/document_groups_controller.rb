class DocumentGroupsController < ApplicationController
  def index
    document_groups = DocumentGroupResource.all(params)
    respond_with(document_groups)
  end

  def show
    document_group = DocumentGroupResource.find(params)
    respond_with(document_group)
  end

  def create
    document_group = DocumentGroupResource.build(params)

    if document_group.save
      render jsonapi: document_group, status: 201
    else
      render jsonapi_errors: document_group
    end
  end

  def update
    document_group = DocumentGroupResource.find(params)

    if document_group.update_attributes
      render jsonapi: document_group
    else
      render jsonapi_errors: document_group
    end
  end

  def destroy
    document_group = DocumentGroupResource.find(params)

    if document_group.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: document_group
    end
  end
end
