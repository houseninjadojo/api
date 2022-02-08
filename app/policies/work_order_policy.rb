class WorkOrderPolicy < ApplicationPolicy
  # authorize :user, allow_nil: true

  def index?
    true
  end

  def show?
    record.property.present? && record.property.user_id
  end

  def create?
    true
  end

  def update?
    record.property.present? && record.property.user_id == user.id
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    relation.includes(:property).where(property: { user_id: user.id })
  end
end
