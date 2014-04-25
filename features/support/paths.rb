module NavigationHelpers
  def path_to(page_name, params = {})
    case page_name
      when "this year's wheresies page"
        wheresies_path Time.now.year
      # We'll want this soon
      #else
      #  begin
      #    page_name =~ /the (.*) page/
      #    path_components = $1.split(/\s+/)
      #    self.send path_components.push('path').join('_').to_sym, params
      #  rescue
      #    raise "Can't map \"#{page_name}\" to a path. Correct your step or add a mapping in #{__FILE__}."
      #  end
    end
  end
end
World(NavigationHelpers)
