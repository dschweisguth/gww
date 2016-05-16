module PersonPhotosSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def photo_search_autocompletions(username, game_statuses)
      people = Person.select("username, realname, count(f.id) photo_count").joins("left join photos f on people.id = f.person_id")
      if username
        people = people.where 'username like ? or realname like ?', "#{username}%", "#{username}%"
      end
      if game_statuses
        people = people.where 'game_status in (?)', game_statuses
      end
      people.
        group("username").order("lower(username)").
        map do |person|
          person.photo_count = person[:photo_count]
          { value: person.username, label: person.photo_search_autocompletion_label }
        end
    end
  end

  def photo_search_autocompletion_label
    "#{username} (#{if realname && realname != username then "#{realname}, " end}#{photo_count})"
  end

end
