module ModelFactory
  def make(options = {})
    make_for_test :new, options
  end

  def make!(options = {})
    make_for_test :create, options
  end

  def process_label!(options)
    padded_label = options.delete(:label).to_s || ''
    if ! padded_label.empty?
      padded_label += '_'
    end
    return options, padded_label
  end
  private :process_label!

end

class FlickrUpdate
  extend ModelFactory

  def self.make_for_test(new_or_create, caller_options = {})
    #noinspection RubyUnusedLocalVariable
    caller_options, padded_label = process_label! caller_options
    options = { :member_count => 0 }
    options.merge! caller_options
    new_or_create == :new ? FlickrUpdate.new(options) : FlickrUpdate.create!(options)
  end
  private_class_method :make_for_test

end

class Person
  extend ModelFactory

  def self.make_for_test(new_or_create, caller_options = {})
    caller_options, padded_label = process_label! caller_options
    options = { :flickrid => padded_label + 'person_flickrid',
      :username => padded_label + 'username' }
    options.merge! caller_options
    new_or_create == :new ? Person.new(options) : Person.create!(options)
  end
  private_class_method :make_for_test

end

class Photo
  extend ModelFactory

  def self.make_for_test(new_or_create, caller_options = {})
    caller_options, padded_label = process_label! caller_options
    now = Time.now
    options = { :flickrid => padded_label + 'photo_flickrid',
      :farm => '0', :server => 'server', :secret => 'secret',
      :dateadded => now, :lastupdate => now, :seen_at => now,
      :mapped => 'false', :game_status => 'unfound', :views => 0 }
    if ! caller_options[:person]
      person_options = {:label => (padded_label + 'poster')}
      options[:person] = new_or_create == :new \
        ? Person.make(person_options) : Person.make!(person_options)
    end
    options.merge! caller_options
    new_or_create == :new ? Photo.new(options) : Photo.create!(options)
  end
  private_class_method :make_for_test

end

class Comment
  extend ModelFactory

  def self.make_for_test(new_or_create, caller_options = {})
    caller_options, padded_label = process_label! caller_options
    options = { :flickrid => padded_label + 'comment_flickrid',
      :username => padded_label + 'comment_username',
      :comment_text => padded_label + 'comment text', :commented_at => Time.now }
    if ! caller_options[:photo]
      photo_options = { :label => (padded_label + 'comment') }
      options[:photo] = new_or_create == :new \
        ? Photo.make(photo_options) : Photo.make!(photo_options)
    end
    options.merge! caller_options
    new_or_create == :new ? Comment.new(options) : Comment.create!(options)
  end

end

class Guess
  extend ModelFactory

  def self.make_for_test(new_or_create, caller_options = {})
    caller_options, padded_label = process_label! caller_options
    now = Time.now
    options = { :guess_text => padded_label + 'guess text', :guessed_at => now, :added_at => now }
    if ! caller_options[:photo]
      photo_options = { :label => (padded_label + 'guess') }
      if caller_options[:photo_person]
        photo_options[:person] = caller_options[:photo_person]
      end
      options[:photo] = new_or_create == :new \
        ? Photo.make(photo_options) : Photo.make!(photo_options)
    end
    caller_options.delete :photo_person
    if ! caller_options[:person]
      person_options = {:label => (padded_label + 'guesser')}
      options[:person] = new_or_create == :new \
        ? Person.make(person_options) : Person.make!(person_options)
    end
    options.merge! caller_options
    new_or_create == :new ? Guess.new(options) : Guess.create!(options)
  end
  private_class_method :make_for_test

end

class Revelation
  extend ModelFactory

  def self.make_for_test(new_or_create, caller_options = {})
    caller_options, padded_label = process_label! caller_options
    now = Time.now
    options = { :revelation_text => padded_label + 'revelation text', :revealed_at => now, :added_at => now }
    if ! caller_options[:photo]
      photo_options = { :label => (padded_label + 'revelation') }
      options[:photo] = new_or_create == :new \
        ? Photo.make(photo_options) : Photo.make!(photo_options)
    end
    options.merge! caller_options
    new_or_create == :new ? Revelation.new(options) : Revelation.create!(options)
  end
  private_class_method :make_for_test

end
