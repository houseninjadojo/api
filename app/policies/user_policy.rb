class UserPolicy < ApplicationPolicy
  authorize :user, allow_nil: true

  def index?
    true
  end

  def show?
    # no user found
    deny! if record.nil?
    # not signed in and trying to resume logging in
    allow! if user.nil? && record.is_currently_onboarding?
    # signed in and checking own user
    record&.id == user&.id
  end

  def create?
    true
  end

  def update?
    allow! if is_setting_password?
    deny! if record.nil?
    if user.present?
      record.id == user.id
    else
      record.try(:hubspot_id).nil? && record.try(:auth_zero_user_created).nil? && record.try(:stripe_customer_id).nil?
    end
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    # next relation if user.admin?
    relation.where(id: user.try(:id))
  end

  private

  def is_setting_password?
    params.dig(:data, :attributes, :password).present?
  end
end
