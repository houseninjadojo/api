# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  amount               :string
#  description          :string
#  originator           :string
#  paid                 :boolean          default(FALSE), not null
#  purpose              :string
#  refunded             :boolean          default(FALSE), not null
#  statement_descriptor :string
#  status               :string
#  stripe_object        :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  invoice_id           :uuid
#  payment_method_id    :uuid
#  stripe_id            :string
#  user_id              :uuid
#
# Indexes
#
#  index_payments_on_invoice_id         (invoice_id)
#  index_payments_on_payment_method_id  (payment_method_id)
#  index_payments_on_status             (status)
#  index_payments_on_stripe_id          (stripe_id) UNIQUE
#  index_payments_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (user_id => users.id)
#
class Payment < ApplicationRecord
  # callbacks

  # associations

  belongs_to :invoice
  belongs_to :payment_method, required: false
  belongs_to :user,           required: false

  # validations

  validates :stripe_id, uniqueness: true, allow_nil: true

  # helpers

  def paid?
    status == 'succeeded'
  end

  def pending?
    status == 'pending'
  end

  def failed?
    status == 'failed'
  end

  def requires_action?
    status == 'requires_action'
  end

  def has_charge?
    stripe_object.present?
  end
  alias was_charged? has_charge?

  # def should_charge?
  #   has_charge? && ['requires_payment_method', 'requires_confirmation'].include?(status)
  # end

  def self.from_stripe_charge!(object)
    ActiveRecord::Base.transaction do
      invoice = Invoice.find_by(stripe_id: object["invoice"]) if object["invoice"].present?
      payment_method = PaymentMethod.find_by(stripe_token: object["payment_method"]) if object["payment_method"].present?
      user = User.find_by(stripe_id: object["customer"]) if object["customer"].present?
      payment = Payment.find_or_initialize_by(stripe_id: object["id"])
      payment.assign_attributes(
        amount: object["amount"],
        description: object["description"],
        invoice: invoice,
        paid: object["paid"],
        payment_method: payment_method,
        refunded: object["refunded"],
        statement_descriptor: object["statement_descriptor"],
        status: object["status"],
        stripe_object: @payload,
        user: user
      )
      payment.save!
      payment
    end
  end

  def self.create_from_payment_intent(object)
    ActiveRecord::Base.transaction do
      invoice = Invoice.find_by(stripe_id: object["invoice"]) if object["invoice"].present?
      payment_method = PaymentMethod.find_by(stripe_token: object["payment_method"]) if object["payment_method"].present?
      user = User.find_by(stripe_id: object["customer"]) if object["customer"].present?
      payment = Payment.find_or_initialize_by(stripe_id: object["id"])
      payment.assign_attributes(
        amount: object["amount"],
        description: object["description"],
        invoice: invoice,
        paid: object["paid"],
        payment_method: payment_method,
        statement_descriptor: object["statement_descriptor"],
        status: object["status"],
        stripe_object: @payload,
        user: user
      )
      payment.save!
      payment
    end
  end

  # actions

  def charge_payment_method!(now: true)
    return if paid? || has_charge? || invoice.nil?

    if now == false
      Sync::Payment::Stripe::Outbound::CreateJob.perform_later(self)
      return
    end

    Sync::Payment::Stripe::Outbound::CreateJob.perform_now(self)
    begin
      payment = self
      Wait.until(sleep_time: 1, max_time: 15) do |counter, time|
        Rails.logger.info "Waiting for invoice to be paid... #{counter} seconds"
        payment.reload.status.present?
      end
      return payment.reload
    rescue Wait::TimeoutError => e
      Rails.logger.info "Invoice payment timed out"
      Sentry.capture_exception(e)
    rescue Wait::LimitError => e
      Rails.logger.info "Invoice payment time limit reached (15"
      Sentry.capture_exception(e)
    rescue StandardError => e
      Rails.logger.info "Invoice payment failed: #{e.message}"
      Sentry.capture_exception(e)
    end
    return nil
  end

  def pay_with_charge!(now: true)
    return if has_charge?
    if now == true
      Stripe::CreateChargeJob.perform_now(self)
    else
      Stripe::CreateChargeJob.perform_later(self)
    end
  end
end
