class Campaign::EstimateApprovalJob < ApplicationJob
  queue_as :default

  def followup_schedule
    [
      {
        subject: "Reminder: You have an estimate ready for review",
        wait: 3.days,
      },
      {
        subject: "Reminder: You have an estimate ready for review",
        wait: 6.days,
      },
      {
        subject: "Review your estimate before it expires!",
        approve_estimate_header: "Don't forget to review your estimate before it expires!",
        wait: 9.days,
      }
    ]
  end

  def perform(estimate:, user:)
    # First Email
    EstimateMailer
      .with(user: user, estimate: estimate)
      .estimate_approval
      .deliver_later

    # Schedule followups
    followup_schedule.each do |followup|
      mailer = EstimateMailer
        .with({
          user: user,
          estimate: estimate,
          subject: followup[:subject],
          approve_estimate_header: followup[:approve_estimate_header],
          only_houseninja: true,
        }.compact)
        .estimate_approval
        .deliver_later(wait: followup[:wait])
      Rails.logger.info("Scheduling followup email in #{followup[:wait]} for estimate=#{estimate.id} - sending #{Time.at(mailer.scheduled_at)}", {
        action_mailer: {
          scheduled_at: mailer.scheduled_at,
          class: 'EstimateMailer',
          action: 'estimate_approval'
        },
        active_job: {
          job_id: job_id,
        },
        resource: {
          id: estimate&.id,
          type: "Estimate",
        },
        usr: {
          id: user&.id,
          email: user&.email,
        },
      })
    end
  end
end
