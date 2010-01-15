class GuessesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @guesses = Guess.find_all
    @guesses.sort! {|x,y| y[:guessed_at] <=> x[:guessed_at]}
  end

  def list_for_graph
    @guesses = Guess.find_all
    @guesses.sort! {|x,y| x[:guessed_at] <=> y[:guessed_at]}
  end

  def time_of_day
    @guesses = Guess.find_all
    @times = []
    @guesses.each do |guess|
      hour = guess[:guessed_at].hour.to_f
      min = ((guess[:guessed_at].min.to_f / 60) * 100).round.to_f / 100
      @times.push(hour + min)
    end
  end
  
  def guesses_vs_photos
    # :TODO: finish...
    @guesses = Guess.find_all
    @guesses.sort! {|x,y| y[:guessed_at] <=> x[:guessed_at]}
    @photos = Photo.find_all
    @photos.sort! {|x,y| y[:dateadded] <=> x[:dateadded]}
    guess_total = 0;
    photo_total = 0;
    first_day = @photos[0][:dateadded]
    first_day.second = first_day.minute = first_day.hour = 0
    check_day = first_day
    last_day = Time.now + 1.day
    days = {}
    while check_day <= last_day
      days[check_day] = {}
      days[check_day].guesses = []
      days[check_day].photos = []
      check_day = check_day + 1.day
    end
  end

  def recently_recorded
    cutoff = Time.now - 1.week
    @guesses = Guess.find(:all, :conditions => ["added_at > ?", cutoff])
    @guesses.sort! {|x,y| y[:added_at] <=> x[:added_at]}
  end

  def recently_guessed
    cutoff = Time.now - 1.week
    @guesses = Guess.find(:all, :conditions => ["added_at > ?", cutoff])
    @guesses.sort! {|x,y| y[:guessed_at] <=> x[:guessed_at]}
  end

  def show
    @guess = Guess.find(params[:id])
  end

  def new
    @guess = Guess.new
  end

  def create
    @guess = Guess.new(params[:guess])
    if @guess.save
      flash[:notice] = 'Guess was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @guess = Guess.find(params[:id])
  end

  def update
    @guess = Guess.find(params[:id])
    if @guess.update_attributes(params[:guess])
      flash[:notice] = 'Guess was successfully updated.'
      redirect_to :action => 'show', :id => @guess
    else
      render :action => 'edit'
    end
  end

  def destroy
    Guess.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
