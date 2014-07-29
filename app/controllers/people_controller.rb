class PeopleController < ApplicationController
  include MultiPhotoMapControllerSupport

  caches_page :autocomplete_usernames
  def autocomplete_usernames
    render json: Person.select(:username).where("username like ?", "#{params[:term]}%").order("lower(username)")
  end

  def find
    username = params[:username]
    person = Person.find_by_multiple_fields username
    if person
      # noinspection RubyResolve
      redirect_to person_path person
    else
      flash[:find_person_error] = username
      redirect_to root_path
    end
  end

  caches_page :index
  def index
    @people = Person.all_sorted params[:sorted_by], params[:order]
  end

  caches_page :nemeses
  def nemeses
    @nemeses = Person.nemeses
  end

  caches_page :top_guessers
  def top_guessers
    @days, @weeks, @months, @years = Person.top_guessers Time.now
  end

  caches_page :show
  def show
    @person = Person.find params[:id].to_i

    @mapped_post_and_guess_count = @person.mapped_photo_count + @person.mapped_guess_count

    @place, @tied = @person.score_standing
    @posts_place, @posts_tied = @person.posts_standing

    now = Time.now
    weekly_high_scorers = Person.high_scorers now, 7
    if weekly_high_scorers.include? @person
      @weekly_high_scorers = weekly_high_scorers
    end
    monthly_high_scorers = Person.high_scorers now, 30
    if monthly_high_scorers.include? @person
      @monthly_high_scorers = monthly_high_scorers
    end
    weekly_top_posters = Person.top_posters now, 7
    if weekly_top_posters.include? @person
      @weekly_top_posters = weekly_top_posters
    end
    monthly_top_posters = Person.top_posters now, 30
    if monthly_top_posters.include? @person
      @monthly_top_posters = monthly_top_posters
    end

    @first_guess = @person.first_guess
    @first_post = @person.first_photo
    @most_recent_guess = @person.most_recent_guess
    @most_recent_post = @person.most_recent_photo

    @oldest_guess = @person.oldest_guess
    @fastest_guess = @person.fastest_guess
    @guess_of_longest_lasting_post = @person.guess_of_longest_lasting_post
    @guess_of_shortest_lasting_post = @person.guess_of_shortest_lasting_post
    @oldest_unfound = @person.oldest_unfound_photo
    @most_commented = @person.most_commented_photo
    @most_viewed = @person.most_viewed_photo
    @most_faved = @person.most_faved_photo

    @guesses = @person.guesses_with_associations
    @favorite_posters = @person.favorite_posters
    @posters = @guesses.group_by { |guess| guess.photo.person }
      .sort do |x,y|
        c = y[1].length <=> x[1].length
        c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
      end

    @posts = @person.photos_with_associations
    @favoring_guessers = @person.favoring_guessers
    @unfound_photos = @person.unfound_photos.to_a
    @revealed_photos = @person.revealed_photos
    @guessers = group_by_guessers @posts
    
  end

  private def group_by_guessers(posts)
    guessers = {}
    posts.each do |post|
      post.guesses.each do |guess|
        guesser = guess.person
        guessers_guesses = guessers[guesser]
        if ! guessers_guesses
          guessers_guesses = []
          guessers[guesser] = guessers_guesses
        end
	      guessers_guesses << post
      end
    end
    guessers.sort do |x,y|
      c = y[1].length <=> x[1].length
      c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
    end
  end

  caches_page :guesses
  def guesses
    @person = Person.find params[:id].to_i
    @guesses = @person.guesses_with_associations_ordered_by_comments
  end

  caches_page :comments
  def comments
    @person = Person.find params[:id].to_i
    @photos = @person.paginated_commented_photos params[:page]
  end

  caches_page :map
  def map
    person_id = params[:id].to_i
    @person = Person.find person_id
    @posts_count = @person.mapped_photo_count
    @guesses_count = @person.mapped_guess_count
    @json = Photo.for_person_for_map(person_id, bounds, MAX_MAP_PHOTOS).to_json
  end

  def map_json
    render json: Photo.for_person_for_map(params[:id].to_i, bounds, MAX_MAP_PHOTOS)
  end

end
