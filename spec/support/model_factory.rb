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

  def self.new_for_test(caller_options = {})
    caller_options, padded_label = process_label! caller_options
    options = { :flickrid => padded_label + 'person_flickrid',
      :username => padded_label + 'username' }
    options.merge! caller_options
    Person.new options
  end

  def self.create_for_test!(caller_options = {})
    caller_options, padded_label = process_label! caller_options
    options = { :flickrid => padded_label + 'person_flickrid',
      :username => padded_label + 'username' }
    options.merge! caller_options
    Person.create! options
  end

end

class Photo
  extend ModelFactorySupport

  def self.new_for_test(caller_options = {})
    caller_options, padded_label = process_label! caller_options
    now = Time.now
    options = { :flickrid => padded_label + 'photo_flickrid',
      :farm => 'farm', :server => 'server', :secret => 'secret',
      :dateadded => now, :lastupdate => now, :seen_at => now,
      :mapped => 'false', :game_status => 'unfound', :views => 0 }
    if ! caller_options[:person]
      options[:person] =
        Person.new_for_test :label => (padded_label + 'poster')
    end
    options.merge! caller_options
    Photo.new options
  end

  def self.create_for_test!(caller_options = {})
    caller_options, padded_label = process_label! caller_options
    now = Time.now
    options = { :flickrid => padded_label + 'photo_flickrid',
      :farm => 'farm', :server => 'server', :secret => 'secret',
      :dateadded => now, :lastupdate => now, :seen_at => now,
      :mapped => 'false', :game_status => 'unfound', :views => 0 }
    if ! caller_options[:person]
      options[:person] =
        Person.create_for_test! :label => (padded_label + 'poster')
    end
    options.merge! caller_options
    Photo.create! options
  end

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

  def self.new_for_test(caller_options = {})
    caller_options, padded_label = process_label! caller_options
    now = Time.now
    options = { :guess_text => 'guess text', :guessed_at => now, :added_at => now }
    if ! caller_options[:photo]
      options[:photo] = Photo.new_for_test :label => (padded_label + 'guess')
    end
    if ! caller_options[:person]
      options[:person] =
        Person.new_for_test :label => (padded_label + 'guesser')
    end
    options.merge! caller_options
    Guess.new options
  end

  def self.create_for_test!(caller_options = {})
    caller_options, padded_label = process_label! caller_options
    now = Time.now
    options = { :guess_text => 'guess text', :guessed_at => now, :added_at => now }
    if ! caller_options[:photo]
      options[:photo] = Photo.create_for_test! :label => (padded_label + 'guess')
    end
    if ! caller_options[:person]
      options[:person] =
        Person.create_for_test! :label => (padded_label + 'guesser')
    end
    options.merge! caller_options
    Guess.create! options
  end

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
