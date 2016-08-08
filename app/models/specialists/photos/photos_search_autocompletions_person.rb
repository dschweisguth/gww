class PhotosSearchAutocompletionsPerson < Person
  def self.photo_search_autocompletions(username, game_statuses)
    people = select("username, realname, count(f.id) photo_count").joins("left join photos f on people.id = f.person_id")
    if username
      people = people.where 'username like ? or realname like ?', "#{username}%", "#{username}%"
    end
    if game_statuses
      people = people.where 'game_status in (?)', game_statuses
    end
    people.
      group("username").order("lower(username)").
      map { |person| { value: person.username, label: person.photo_search_autocompletion_label } }
  end

  def photo_search_autocompletion_label
    "#{username} (#{if realname && realname != username then "#{realname}, " end}#{photo_count})"
  end

end
