class InvoicesController < ApplicationController
  def index
    invoices = InvoiceResource.all(params)
    respond_with(invoices)
  end

  def show
    invoice = InvoiceResource.find(params)
    respond_with(invoice)
  end

  def create
    invoice = InvoiceResource.build(params)

    if invoice.save
      render jsonapi: invoice, status: 201
    else
      render jsonapi_errors: invoice
    end
  end

  def update
    invoice = InvoiceResource.find(params)

    if invoice.update_attributes
      render jsonapi: invoice
    else
      render jsonapi_errors: invoice
    end
  end

  def destroy
    invoice = InvoiceResource.find(params)

    if invoice.destroy
      render jsonapi: { meta: {} }, status: 200
    else
      render jsonapi_errors: invoice
    end
  end
end
