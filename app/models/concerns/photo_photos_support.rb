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
      # noinspection RubyResolve
      photos.each { |photo| photo.prepare_for_map first_photo.dateadded }
      as_map_json partial, bounds, photos
    end

    def find_with_associations(id)
      includes(:person, :revelation, guesses: :person).find id
    end

    def unfound_or_unconfirmed
      where("game_status in ('unfound', 'unconfirmed')").order('lastupdate desc').includes(:person, :tags)
    end

    ORDERS = {
      'date-taken' => 'datetaken',
      'date-added' => 'dateadded',
      'last-updated' => 'lastupdate'
    }

    def search_defaults(params)
      {
        did: 'posted',
        sorted_by: params[:did] == 'activity' ? 'date-taken' : 'last-updated',
        direction: '-',
        page: 1,
        per_page: 30
      }
    end

    def search(did:, done_by: nil, text: nil, game_status: nil, from_date: nil, to_date: nil,
      sorted_by:, direction:, page:, per_page:)
      query = all
      if did == 'activity' && done_by
        query = query.select("*", "activities.acted_at acted_on_at")
          .joins(%q(join (
            select f1.id, f1.datetaken acted_at from photos f1 join people p on p.id = f1.person_id and p.username = %s
            union
            select c.photo_id, c.commented_at from comments c where c.username = %s) activities on activities.id = photos.id
          ) % Array.new(2, ActiveRecord::Base.sanitize(done_by)))
        if from_date
          query = query.where "? <= activities.acted_at", from_date
        end
        if to_date
          query = query.where "activities.acted_at < ?", to_date + 1.day
        end
        query = query
          .order("acted_on_at #{direction == '+' ? 'asc' : 'desc'}")
          .includes(:person, :tags, :comments)
        # .includes mostly doesn't work here; in general it seems not to work with queries that return the same object
        # more than once. I posted to rubyonrails-talk to see whether this is a bug and got no response:
        # https://groups.google.com/forum/#!searchin/rubyonrails-talk/includes/rubyonrails-talk/Pn1weH5Kz7Y/BCSS_HUdBuoJ
        # This Rails issue might be the same: https://github.com/rails/rails/issues/16436 # TODO Dave check back
      else
        if done_by
          query = query.joins(:person).where(people: { username: done_by })
        end
        text.try :each do |words|
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
        if game_status
          query = query.where game_status: game_status
        end
        if from_date
          query = query.where "? <= dateadded", from_date
        end
        if to_date
          query = query.where "dateadded < ?", to_date + 1.day
        end
        query = query
          .order("#{ORDERS[sorted_by]} #{direction == '+' ? 'asc' : 'desc'}")
          .includes(:person)
      end
      query.paginate page: page, per_page: per_page
    end

  end

  def human_tags
    tags.reject &:machine_tag
  end

  def machine_tags
    tags.select &:machine_tag
  end

  def comments_that_match(text_term_groups)
    comments.select { |comment| text_term_groups.any? { |terms| terms.all? { |text| comment.comment_text =~ /\b#{text}\b/i } } }
  end

  # A confusing method. Returns an array of comments which is an array for the caller's convenience but which is
  # expected to contain only one element, the comment which led to this photo being including in activity search results.
  def comments_made_when_acted_on
    # For performance, expect this photo's comments to have been included and select from them in memory
    comments.select { |comment| comment.commented_at == self[:acted_on_at] }
  end

end
