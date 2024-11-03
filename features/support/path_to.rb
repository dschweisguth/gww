module PathTo
  def path_to(page_name)
    case page_name
      ### Players

      when "the home page"
        root_path
      when /^the photos page sorted by (.*)$/
        photos_path sorted_by: Regexp.last_match(1), order: '+', page: 1
      when "the photos map page"
        map_photos_path
      when "the photos search page"
        search_photos_path
      when /^the player "([^"]+)"'s page$/
        person_path Person.find_by_username(Regexp.last_match(1))
      when "the photo's page"
        photo_path @photo

      ### Admins

      when "the admin home page"
        admin_root_path
      when "the admin inaccessible photos page"
        inaccessible_admin_photos_path
      when "the photo's edit page"
        edit_admin_photo_path @photo

      else
        # :nocov:
        raise "Unknown page name: #{page_name}"
        # :nocov:
    end
  end
end
World PathTo
