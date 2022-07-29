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
    record&.id == user&.id || record.try(:user_id) == user&.id
  end

  def create?
    true
  end

  def update?
    deny! if record.nil?
    allow! if is_setting_password?
    allow! if is_onboarding?
    record&.id == user&.id
  end

  def destroy?
    record&.id == user&.id
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

  def is_onboarding?
    # record.try(:is_currently_onboarding?) &&
    params.dig(:data, :attributes, :onboarding_step).present?
  end
end
