module ApplicationHelper


def sortable(column, title = nil)
  search=params[:search]
  title ||= column.titleize
  css_class = column == sort_column ? "current #{sort_direction}" : nil
  direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
  link_to title, {search: search, :sort => column, :direction => direction}, {:class => css_class}
end



end
