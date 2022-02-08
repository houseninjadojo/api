class UserPolicy < ApplicationPolicy
  # See https://actionpolicy.evilmartians.io/#/writing_policies
  #
  # def index?
  #   true
  # end
  #
  # def update?
  #   # here we can access our context and record
  #   user.admin? || (user.id == record.user_id)
  # end

  authorize :user, allow_nil: true

  def index?
    true
  end

  def show?
    user.id == record.id
  end

  def create?
    true
  end

  def update?
    if user.present?
      user.id == record.id
    else
      record.hubspot_id.nil? && record.auth_zero_user_created.nil? && record.stripe_customer_id.nil?
    end
  end

  def destroy?
    false
  end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  relation_scope do |relation|
    # next relation if user.admin?
    relation.where(id: user.id)
  end
end
