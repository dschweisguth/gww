module PhotoPhotosSupport
  extend ActiveSupport::Concern
  include MultiPhotoMapSupport

  module ClassMethods

    def all_sorted_and_paginated(sorted_by, order, page, per_page)
      paginate_by_sql(
        %Q[
          select p.*
            from photos p, people poster
            where p.person_id = poster.id
            order by #{order_by(sorted_by, order)}
        ],
        page: page, per_page: per_page)
    end

    SORTED_BY = {
      'username' => { secondary: [ 'date-added' ],
        column: 'lower(poster.username)', default_order: '+' },
      'date-added' => { secondary: [ 'username' ],
        column: 'dateadded', default_order: '-' },
      'last-updated' => { secondary: [ 'username' ],
        column: 'lastupdate', default_order: '-' },
      'views' => { secondary: [ 'username' ],
        column: 'views', default_order: '-' },
      'faves' => { secondary: [ 'username' ],
        column: 'faves', default_order: '-' },
      'comments' => { secondary: [ 'username' ],
        column: 'other_user_comments', default_order: '-' },
      'member-comments' => { secondary: [ 'date-added', 'username' ],
        column: 'member_comments', default_order: '-' },
      'member-questions' => { secondary: [ 'date-added', 'username' ],
        column: 'member_questions', default_order: '-' }
    }

    private def order_by(sorted_by, order)
      term_names = [ sorted_by, *SORTED_BY[sorted_by][:secondary] ]
      terms = term_names.map do |term_name|
        term = SORTED_BY[term_name][:column]
        if SORTED_BY[term_name][:default_order] != order
          term += ' desc'
        end
        term
      end
      terms.join ', '
    end

    def all_for_map(bounds, max_count)
      photos = mapped bounds, max_count + 1
      partial = photos.length == max_count + 1
      if partial
        photos.to_a.pop
      end
      first_photo = oldest
      photos.each { |photo| photo.prepare_for_map first_photo.dateadded }
      as_map_json partial, bounds, photos
    end

    def find_with_associations(id)
      includes(:person, :revelation, { guesses: :person }).find id
    end

    def unfound_or_unconfirmed
      where("game_status in ('unfound', 'unconfirmed')").order('lastupdate desc').includes(:person, :tags)
    end

    def search(terms, sorted_by, direction, page)
      query = all
      if terms.has_key? 'game-status'
        query = query.where game_status: terms['game-status']
      end
      if terms.has_key? 'posted-by'
        query = query.joins(:person).where people: { username: terms['posted-by'] }
      end
      if terms['text']
        terms['text'].each do |words|
          clauses = [
            "title regexp ?",
            "description regexp ?",
            "exists (select 1 from tags t where photos.id = t.photo_id and lower(t.raw) regexp ?)"
          ]
          sql = clauses.map { |clause| Array.new(words.length) { clause }.join(" and ") + " or " }.join +
            "exists (select 1 from comments c where photos.id = c.photo_id and (#{Array.new(words.length) { "c.comment_text regexp ?" }.join " and " }))"
          query = query.where(sql, *Array.new(clauses.length + 1, words).flatten.map { |word| "[[:<:]]#{word.downcase}[[:>:]]" })
            .includes :tags, :comments # because we display them when it's a text search
        end
      end
      if terms.has_key? 'from-date'
        query = query.where "? <= dateadded", Date.parse_utc_time(terms['from-date'])
      end
      if terms.has_key? 'to-date'
        query = query.where "dateadded < ?", Date.parse_utc_time(terms['to-date']) + 1.day
      end
      query
        .order("#{sorted_by == 'date-added' ? 'dateadded' : 'lastupdate'} #{direction == '+' ? 'asc' : 'desc'}")
        .includes(:person)
        .paginate page: page, per_page: 30
    end

  end

  def comments_that_match(text_term_groups)
    comments.select { |comment| text_term_groups.any? { |terms| terms.all? { |text| comment.comment_text =~ /\b#{text}\b/i } } }
  end

  def human_tags
    tags.select { |tag| !tag.machine_tag }
  end

  def machine_tags
    tags.select &:machine_tag
  end

end
