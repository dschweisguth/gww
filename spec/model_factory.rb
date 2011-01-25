class Hash
  def -(*keys)
    #noinspection RubyUnusedLocalVariable
    reject { |key, value| keys.include?(key) }
  end
end

module ModelFactorySupport
  def process_prefix!(options)
    prefix = options[:prefix]
    if prefix
      options.delete :prefix
    else
      prefix = ''
    end
    padded_prefix = prefix == '' ? '' : prefix + '_'
    return options, prefix, padded_prefix
  end
  private :process_prefix!
end

class Person
  extend ModelFactorySupport

  def self.create_for_test!(options)
    #noinspection RubyUnusedLocalVariable
    options, prefix, padded_prefix = process_prefix! options
    Person.create! :flickrid => padded_prefix + 'person_flickrid',
      :username => padded_prefix + 'username'
  end

end

class Photo
  extend ModelFactorySupport

  def self.create_for_test!(caller_options)
    #noinspection RubyUnusedLocalVariable
    caller_options, prefix, padded_prefix = process_prefix! caller_options
    now = Time.now
    poster = Person.create_for_test! :prefix => (padded_prefix + 'poster')
    options = { :person => poster,
      :flickrid => padded_prefix + 'photo_flickrid',
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
    caller_options, prefix, padded_prefix = process_prefix! caller_options
    now = Time.now
    options = { :guess_text => 'guess text', :guessed_at => now, :added_at => now }
    if ! caller_options[:photo]
      options[:photo] = Photo.create_for_test! :prefix => prefix
    end
    if ! caller_options[:person]
      options[:person] =
        Person.create_for_test! :prefix => (padded_prefix + 'guesser')
    end
    options.merge! caller_options
    Guess.create! options
  end

end

class Comment
  extend ModelFactorySupport

  def self.create_for_test!(caller_options)
    caller_options, prefix, padded_prefix = process_prefix! caller_options
    options = { :flickrid => padded_prefix + 'comment_flickrid',
      :username => padded_prefix + 'comment_username',
      :comment_text => 'comment_text', :commented_at => Time.now }
    if ! caller_options[:photo]
      options[:photo] = Photo.create_for_test! :prefix => prefix
    end
    options.merge! caller_options
    Comment.create! options
  end

end
