module GWW
  module Helpers
    module Model
      def make_potential_favorite_poster(factory_prefix, posts_by_favorite, posts_by_others)
        person_factory = "#{factory_prefix}_person"
        photo_factory = "#{factory_prefix}_photo"
        favorite_poster = create person_factory
        devoted_guesser = create person_factory
        posts_by_favorite.times do
          photo = create photo_factory, person: favorite_poster
          create :guess, person: devoted_guesser, photo: photo
        end
        other_poster = create person_factory
        posts_by_others.times do
          create photo_factory, person: other_poster
        end
        return devoted_guesser, favorite_poster
      end
    end
  end
end
