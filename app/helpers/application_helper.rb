module ApplicationHelper
  def flash_icon(type)
    icons = {
      'notice'  => '✓',
      'success' => '✓',
      'alert'   => '⚠',
      'danger'  => '✕',
      'warning' => '⚠',
      'info'    => 'ℹ'
    }
    icons[type.to_s] || 'ℹ'
  end

  def status_badge(status)
    content_tag(:span, t("tasks.statuses.#{status}"), class: "badge badge-#{status}")
  end

  def priority_badge(priority)
    content_tag(:span, t("tasks.priorities.#{priority}"), class: "badge badge-#{priority}")
  end
  
  def task_status_color(status)
    case status
    when "pending"   then "#ff9800"   # orange
    when "in_progress" then "#2196f3" # blue
    when "completed" then "#4caf50"   # green
    when "cancelled" then "#9e9e9e"   # grey
    else "#757575"
    end
  end

  def task_priority_color(priority)
    case priority
    when "high"    then "#f44336"   # red
    when "medium"  then "#ff9800"   # orange
    when "low"     then "#4caf50"   # green
    else "#9e9e9e"
    end
  end
end