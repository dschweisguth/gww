module PathTo
  def path_to(page_name, params = {})
    case page_name
      when "the home page"
        root_path
      when "the admin home page"
        admin_root_path
      # We'll need this eventually
      # else
      #   begin
      #      page_name =~ /the (.*) page/
      #      path_components = $1.split(/\s+/)
      #      self.send path_components.push('path').join('_').to_sym, params
      #   rescue
      #      raise "Can't map \"#{page_name}\" to a path. Correct your step or add a mapping in #{__FILE__}."
      #   end
    end
  end
end
World PathTo
