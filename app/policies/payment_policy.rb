class PaymentPolicy < ApplicationPolicy
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
    false
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    relation
      .includes(:payment_method)
      .where(payment_method: { user_id: user.try(:id) })
      .or(relation.where(user_id: user.try(:id)))
  end
end
