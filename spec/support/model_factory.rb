module ModelFactorySupport
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
  extend ModelFactorySupport

  def self.create_for_test!(caller_options = {})
    #noinspection RubyUnusedLocalVariable
    caller_options, padded_label = process_label! caller_options
    options = { :member_count => 0 }
    options.merge! caller_options
    FlickrUpdate.create! options
  end

end

class Person
  extend ModelFactorySupport

  def self.new_for_test(options = {})
    make_for_test :new, options
  end

  def self.create_for_test!(options = {})
    make_for_test :create, options
  end

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
  extend ModelFactorySupport

  def self.new_for_test(options = {})
    make_for_test :new, options
  end

  def self.create_for_test!(options = {})
    make_for_test :create, options
  end

  def self.make_for_test(new_or_create, caller_options = {})
    caller_options, padded_label = process_label! caller_options
    now = Time.now
    options = { :flickrid => padded_label + 'photo_flickrid',
      :farm => 'farm', :server => 'server', :secret => 'secret',
      :dateadded => now, :lastupdate => now, :seen_at => now,
      :mapped => 'false', :game_status => 'unfound', :views => 0 }
    if ! caller_options[:person]
      person_options = {:label => (padded_label + 'poster')}
      options[:person] = new_or_create == :new \
        ? Person.new_for_test(person_options) : Person.create_for_test!(person_options)
    end
    options.merge! caller_options
    new_or_create == :new ? Photo.new(options) : Photo.create!(options)
  end
  private_class_method :make_for_test

end

class Comment
  extend ModelFactorySupport

  def self.create_for_test!(caller_options = {})
    caller_options, padded_label = process_label! caller_options
    options = { :flickrid => padded_label + 'comment_flickrid',
      :username => padded_label + 'comment_username',
      :comment_text => 'comment_text', :commented_at => Time.now }
    if ! caller_options[:photo]
      options[:photo] = Photo.create_for_test! :label => (padded_label + 'comment')
    end
    options.merge! caller_options
    Comment.create! options
  end

end

class Guess
  extend ModelFactorySupport

  def self.new_for_test(options = {})
    make_for_test :new, options
  end

  def self.create_for_test!(options = {})
    make_for_test :create, options
  end

  def self.make_for_test(new_or_create, caller_options = {})
    caller_options, padded_label = process_label! caller_options
    now = Time.now
    options = { :guess_text => 'guess text', :guessed_at => now, :added_at => now }
    if ! caller_options[:photo]
      photo_options = { :label => (padded_label + 'guess') }
      if caller_options[:photo_person]
        photo_options[:person] = caller_options[:photo_person]
      end
      options[:photo] = new_or_create == :new \
        ? Photo.new_for_test(photo_options) : Photo.create_for_test!(photo_options)
    end
    caller_options.delete :photo_person
    if ! caller_options[:person]
      person_options = {:label => (padded_label + 'guesser')}
      options[:person] = new_or_create == :new \
        ? Person.new_for_test(person_options) : Person.create_for_test!(person_options)
    end
    options.merge! caller_options
    new_or_create == :new ? Guess.new(options) : Guess.create!(options)
  end
  private_class_method :make_for_test

end

class Revelation
  extend ModelFactorySupport

  def self.create_for_test!(caller_options = {})
    caller_options, padded_label = process_label! caller_options
    now = Time.now
    options = { :revelation_text => 'revelation text', :revealed_at => now, :added_at => now }
    if ! caller_options[:photo]
      options[:photo] = Photo.create_for_test! :label => (padded_label + 'revelation')
    end
    options.merge! caller_options
    Revelation.create! options
  end

end
