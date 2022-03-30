class WorkOrderPolicy < ApplicationPolicy
  # authorize :user, allow_nil: true

  def index?
    true
  end

  def show?
    deny! if record.nil? || user.nil? || record.property.nil?
    record.property.user_id == user.id
  end

  def create?
    false
  end

  def update?
    deny! if record.nil? || user.nil? || record.property.nil?
    record.property.user_id == user.id
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    relation.includes(:property).where(property: { user_id: user.try(:id) })
  end
end
