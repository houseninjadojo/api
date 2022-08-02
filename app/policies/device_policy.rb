class DevicePolicy < ApplicationPolicy
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
    deny! if record.nil? || user.nil?
    user_id = params.dig(:data, :relationships, :user, :data, :id)
    record.user_id == user.id || user_id == user.id
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    # next relation if user.admin?
    if user.present?
      relation.where(user: user)
    else
      relation.none
    end
  end
end
