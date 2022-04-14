class DocumentPolicy < ApplicationPolicy
  # authorize :user, allow_nil: true

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
    deny! if record.nil? || user.nil?
    record.user_id == user.id
  end

  def destroy?
    deny! if record.nil? || user.nil?
    record.user_id == user.id
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    relation
      .includes(:property, :invoice)
      .where(property: { user_id: user.try(:id) })
      .or(relation.where(invoice: { user_id: user.try(:id) }))
      .or(relation.where(user_id: user.try(:id)))
  end
end
