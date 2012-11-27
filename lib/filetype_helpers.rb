module Sinatra
  module FiletypeHelpers
    def file_type(file_name)
      case File.extname(file_name).downcase
      when '.html', '.htm' then :html
      when '.css' then :css
      when '.js' then :js
      when '.png', '.gif', '.jpg', '.jpeg' then :image
      else :unknown
      end
    end
    def is_editable?(file_type)
      [:html, :css, :js].include? file_type
    end
    def is_viewable?(file_type)
      [:html, :image].include? file_type
    end
  end

  helpers FiletypeHelpers
end
