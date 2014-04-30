module PathTo
  def path_to(page_name)
    case page_name
      ### Players

      when "the home page"
        root_path
      when "the photos search page"
        search_photos_path
      when /^the player "([^"]+)"'s page$/
        person_path Person.find_by_username($1)

      ### Admins

      when "the admin home page"
        admin_root_path
      when "the photo's edit page"
        edit_admin_photo_path @photo

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
