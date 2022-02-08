class InvoicePolicy < ApplicationPolicy
  authorize :user, allow_nil: true

  def index?
    true
  end

  def show?
    record.user_id == user.id
  end

  def create?
    true
  end

  def update?
    record.user_id == user.id
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    # next relation if user.admin?
    # invoice => payment => payment_method.user_id = ? OR invoice.user_id = ?
    relation
      .includes(payment: [:payment_method])
      .where(payment: { payment_methods: { user_id: user.id } })
      .or(relation.where(user_id: user.id))
  end
end
