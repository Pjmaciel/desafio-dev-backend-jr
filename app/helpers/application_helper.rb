module ApplicationHelper
  def format_key(key)
    key.to_s.tr('_', ' ').split.map(&:capitalize).join(' ')
  end
end
