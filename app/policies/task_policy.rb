class TaskPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user&.admin?
      scope.where(project_id: user.projects.select(:id))
    end
  end

  
  def index?
    true   
  end
  def show?
    return true if user&.admin?
    user.present? && user.can_view_project?(record.project)
  end

  def create?
    return true if user&.admin?
    user.present? && user.can_contribute_to?(record.project)
  end

  def new?
    create?
  end

  def update?
    return true if user&.admin?
    user.present? && (user.can_contribute_to?(record.project) || record.creator == user)
  end

  def destroy?
    return true if user&.admin?
    user.present? && user.can_delete_task?(record)
  end
end