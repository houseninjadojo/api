class InvoicesController < ApplicationController
  def index
    authorize!
    scope = authorized_scope(Invoice.all)
    invoices = InvoiceResource.all(params, scope)
    respond_with(invoices)
  end

  def show
    invoice = InvoiceResource.find(params)
    authorize! invoice.data
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
end
