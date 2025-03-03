class DocumentGroupPolicy < ApplicationPolicy
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
    relation.where(user_id: user.try(:id))
  end
end
