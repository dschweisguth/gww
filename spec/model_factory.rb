class Hash
  def -(*keys)
    #noinspection RubyUnusedLocalVariable
    reject { |key, value| keys.include?(key) }
  end
end

module ModelFactorySupport
  def process_label!(options)
    label = options[:label]
    if label
      options.delete :label
    else
      label = ''
    end
    padded_label = label == '' ? '' : label + '_'
    return options, label, padded_label
  end
  private :process_label!
end

class Person
  extend ModelFactorySupport

  def self.create_for_test!(options)
    #noinspection RubyUnusedLocalVariable
    options, label, padded_label = process_label! options
    Person.create! :flickrid => padded_label + 'person_flickrid',
      :username => padded_label + 'username'
  end

end

class Photo
  extend ModelFactorySupport

  def self.create_for_test!(caller_options)
    #noinspection RubyUnusedLocalVariable
    caller_options, label, padded_label = process_label! caller_options
    now = Time.now
    poster = Person.create_for_test! :label => (padded_label + 'poster')
    options = { :person => poster,
      :flickrid => padded_label + 'photo_flickrid',
      :farm => 'farm', :server => 'server', :secret => 'secret',
      :dateadded => now, :lastupdate => now, :seen_at => now,
      :mapped => 'false', :game_status => 'unfound', :views => 0 }
    options.merge! caller_options
    Photo.create! options
  end

end

class Guess
  extend ModelFactorySupport

  def self.create_for_test!(caller_options)
    caller_options, label, padded_label = process_label! caller_options
    now = Time.now
    options = { :guess_text => 'guess text', :guessed_at => now, :added_at => now }
    if ! caller_options[:photo]
      options[:photo] = Photo.create_for_test! :label => label
    end
    if ! caller_options[:person]
      options[:person] =
        Person.create_for_test! :label => (padded_label + 'guesser')
    end
    options.merge! caller_options
    Guess.create! options
  end

end

class Comment
  extend ModelFactorySupport

  def self.create_for_test!(caller_options)
    caller_options, label, padded_label = process_label! caller_options
    options = { :flickrid => padded_label + 'comment_flickrid',
      :username => padded_label + 'comment_username',
      :comment_text => 'comment_text', :commented_at => Time.now }
    if ! caller_options[:photo]
      options[:photo] = Photo.create_for_test! :label => label
    end
    options.merge! caller_options
    Comment.create! options
  end

end

class FlickrUpdate
  extend ModelFactorySupport

  def self.create_for_test!(caller_options)
    #noinspection RubyUnusedLocalVariable
    caller_options, label, padded_label = process_label! caller_options
    options = { :member_count => 0 }
    options.merge! caller_options
    FlickrUpdate.create! options
  end

end
