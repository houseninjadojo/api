class InvoicesController < ApplicationController
  before_action :authenticate_request!, except: [:show]

  def index
    authorize!
    scope = authorized_scope(Invoice.all)
    invoices = InvoiceResource.all(params, scope)
    respond_with(invoices)
  end

  def show
    # if access token is present, use it to find the invoice
    # as well, bypass authorization context
    # otherwise, use the id as usual
    if access_token.present?
      invoice_record = Invoice.find_by(access_token: access_token)
      params[:id] = invoice_record.id
      user = access_token_user
    else
      user = current_user
    end
    invoice = InvoiceResource.find(params)
    authorize!(invoice.data, context: { user: user })
    respond_with(invoice)
  end

  def create
    authorize!
    invoice = InvoiceResource.build(params)

    if invoice.save
      render jsonapi: invoice, status: 201
    else
      render jsonapi_errors: invoice
    end
  end

  def update
    invoice = InvoiceResource.find(params)
    authorize! invoice.data

    if invoice.update_attributes
      render jsonapi: invoice
    else
      render jsonapi_errors: invoice
    end
  end

  def destroy
    invoice = InvoiceResource.find(params)
    authorize! invoice.data

    if invoice.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: invoice
    end
  end

  private

  # decrypt and reveal access token, or nil
  # access token is derived from id
  def access_token_payload
    @access_token_payload ||= begin
      payload = params.fetch(:id, nil)
      EncryptionService.decrypt(payload)&.with_indifferent_access
    rescue => e
      nil
    end
  end

  def access_token
    @access_token ||= access_token_payload&.fetch(:access_token, nil)
  end

  def access_token_user
    @access_token_user ||= begin
      user_id = access_token_payload&.fetch(:user_id, nil)
      User.find_by(id: user_id)
    end
  end
end
