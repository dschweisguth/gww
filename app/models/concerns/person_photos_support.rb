module PersonPhotosSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def all_for_autocomplete(username, game_statuses)
      people = Person.select("people.username, count(f.id) n").joins("left join photos f on people.id = f.person_id")
      if username
        people = people.where 'people.username like ?', "#{username}%"
      end
      if game_statuses
        people = people.where 'game_status in (?)', game_statuses
      end
      people = people.group("people.username").order("lower(username)")
      people.each { |person| person.label = "#{person.username} (#{person[:n]})" }
    end
  end

end
