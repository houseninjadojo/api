class PaymentMethodPolicy < ApplicationPolicy
  authorize :user, allow_nil: true

  def index?
    true
  end

  def show?
    record.user_id = user.id
  end

  def create?
    true
  end

  def update?
    record.user_id = user.id
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    relation.where(user_id: user.id)
  end
end
