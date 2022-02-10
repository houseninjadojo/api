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
    puts "\n\n\n\nDEVICE UPDATE POLICY - RECORD: #{record}"
    puts "DEVICE UPDATE POLICY - RECORD USERID: #{record.user_id}"
    deny! if record.nil? || user.nil?
    record.user_id == user.id
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    # next relation if user.admin?
    relation.where(user: user)
  end
end
