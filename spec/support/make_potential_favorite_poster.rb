def make_potential_favorite_poster(posts_by_favorite, posts_by_others)
  favorite_poster = create :person
  devoted_guesser = create :person
  posts_by_favorite.times do
    photo = create :photo, person: favorite_poster
    create :guess, person: devoted_guesser, photo: photo
  end
  other_poster = create :person
  posts_by_others.times do
    create :photo, person: other_poster
  end
  return devoted_guesser, favorite_poster
end
