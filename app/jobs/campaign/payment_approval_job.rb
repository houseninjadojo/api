class Campaign::PaymentApprovalJob < ApplicationJob
  queue_as :default

  def followup_schedule
    [
      {
        subject: "Reminder: You have an invoice ready for payment",
        wait: 3.days,
      },
      {
        subject: "Reminder: You have an invoice ready for payment",
        wait: 6.days,
      },
      {
        subject: "You have an overdue invoice",
        approve_invoice_message: "Your invoice is overdue. Please make payment as soon as possible.",
        wait: 9.days,
      }
    ]
  end

  def perform(invoice:, user:)
    # First Email
    InvoiceMailer
      .with(user: user, invoice: invoice)
      .payment_approval
      .deliver_later

    # Schedule followups
    followup_schedule.each do |followup|
      mailer = InvoiceMailer
        .with({
          user: user,
          invoice: invoice,
          subject: followup[:subject],
          approve_invoice_message: followup[:approve_invoice_message]
        }.compact)
        .payment_approval
        .deliver_later(wait: followup[:wait])
      Rails.logger.info("Scheduling followup email in #{followup[:wait]} for invoice=#{invoice.id} - sending #{Time.at(mailer.scheduled_at)}", {
        action_mailer: {
          scheduled_at: mailer.scheduled_at,
          class: 'InvoiceMailer',
          action: 'payment_approval'
        },
        active_job: {
          job_id: job_id,
        },
        usr: {
          id: user&.id,
          email: user&.email,
        },
      })
    end
  end
end
