class TaskPolicy < ApplicationPolicy
  class Scope < Scope

    def resolve
      scope.all
    end
  end

  
  def index?
    true   
  end

  def show?
    record.project == @project && user.projects.exists?(record.project_id)
    
  end
end