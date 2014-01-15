module ApplicationHelper
  def sortable(column, title = nil)
    search=params[:search]
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {search: search, :sort => column, :direction => direction}, {:class => css_class}
  end
  def pagination_links(collection, options = {})
    options[:renderer] ||= BootstrapPaginationHelper::LinkRenderer
    options[:class] ||= 'pagination pagination-centered'
    options[:inner_window] ||= 2
    options[:outer_window] ||= 1
    will_paginate(collection, options)
  end


  def coderay(text)
    text.gsub!(/\n/, '<br>')
    text.gsub!(/\<code(?: lang="(.+?)")?\>(.+?)\<\/code\>/m) do
      lang = $1
      content = $2.gsub(/<br>/, '')
      begin
      code = CodeRay.scan(content, lang).div()
      rescue
        code = content
      end
      "<notextile>#{code}</notextile>"
    end
    return text.html_safe
  end


end
