class EstimatePolicy < ApplicationPolicy
  authorize :user, allow_nil: true

  def index?
    true
  end

  def show?
    deny! if record.nil? || user.nil?
    record&.user&.id == user.id
  end

  def create?
    true
  end

  def update?
    deny! if record.nil? || user.nil?
    user_id = params.dig(:data, :relationships, :user, :data, :id)
    record.user.id == user.id || user_id == user.id
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    relation
      .includes(work_order: [:property])
      .where(property: { user_id: user.try(:id) })
  end
end
