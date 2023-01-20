class PropertyPolicy < ApplicationPolicy
  authorize :user, allow_nil: true

  def index?
    true
  end

  def show?
    deny! if record.nil? || user.nil?
    record.user_id == user.id
  end

  def create?
    true
  end

  def update?
    deny! if record.nil?
    allow! if is_onboarding?
    record&.user_id == user&.id
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    relation.where(user_id: user.try(:id))
  end

  private

  def is_onboarding?
    user_id = params.dig(:data, :relationships, :user, :data, :id)
    User.find_by(id: user_id).try(:is_currently_onboarding?)
  end
end
