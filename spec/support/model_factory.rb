module ModelFactory
  def make(label = '', options = {})
    parse_args_and_make_for_test :new, label, options
  end

  def make!(label = '', options = {})
    parse_args_and_make_for_test :create, label, options
  end

  def parse_args_and_make_for_test(new_or_create, label, options)
    if label.is_a? Hash
      options = label
      label = ''
    end
    padded_label = label.to_s
    if ! padded_label.empty?
      padded_label += '_'
    end
    make_for_test new_or_create, padded_label, options
  end
  private :parse_args_and_make_for_test

end

class FlickrUpdate
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.make_for_test(new_or_create, padded_label, caller_options)
    options = { :member_count => 0 }
    if new_or_create == :new && ! caller_options[:created_at]
      options[:created_at] = Time.now
    end
    options.merge! caller_options
    update = new_or_create == :new ? FlickrUpdate.new(options) : FlickrUpdate.create!(options)
    update
  end
  private_class_method :make_for_test

end

class Person
  extend ModelFactory

  def self.make_for_test(new_or_create, padded_label, caller_options)
    options = {
      :flickrid => padded_label + 'person_flickrid',
      :username => padded_label + 'username'
    }
    options.merge! caller_options
    new_or_create == :new ? Person.new(options) : Person.create!(options)
  end
  private_class_method :make_for_test

end

class Photo
  extend ModelFactory

  def self.make_for_test(new_or_create, padded_label, caller_options)
    now = Time.now
    options = {
      :flickrid => padded_label + 'photo_flickrid',
      :farm => '0',
      :server => 'server',
      :secret => 'secret',
      :dateadded => now,
      :lastupdate => now,
      :seen_at => now,
      :mapped => 'false',
      :game_status => 'unfound',
      :views => 0
    }
    if ! caller_options[:person]
      person_label = padded_label + 'poster'
      options[:person] =
        new_or_create == :new ? Person.make(person_label) : Person.make!(person_label)
    end
    options.merge! caller_options
    new_or_create == :new ? Photo.new(options) : Photo.create!(options)
  end
  private_class_method :make_for_test

end

class Comment
  extend ModelFactory

  def self.make_for_test(new_or_create, padded_label, caller_options)
    options = {
      :flickrid => padded_label + 'comment_flickrid',
      :username => padded_label + 'comment_username',
      :comment_text => padded_label + 'comment text',
      :commented_at => Time.now
    }
    if ! caller_options[:photo]
      photo_label = padded_label + 'comment'
      options[:photo] =
        new_or_create == :new ? Photo.make(photo_label) : Photo.make!(photo_label)
    end
    options.merge! caller_options
    new_or_create == :new ? Comment.new(options) : Comment.create!(options)
  end

end

class Guess
  extend ModelFactory

  def self.make_for_test(new_or_create, padded_label, caller_options)
    now = Time.now
    options = {
      :guess_text => padded_label + 'guess text',
      :guessed_at => now,
      :added_at => now
    }
    if ! caller_options[:photo]
      photo_label = padded_label + 'guess'
      options[:photo] =
        new_or_create == :new ? Photo.make(photo_label) : Photo.make!(photo_label)
    end
    if ! caller_options[:person]
      person_label = padded_label + 'guesser'
      options[:person] =
        new_or_create == :new ? Person.make(person_label) : Person.make!(person_label)
    end
    options.merge! caller_options
    new_or_create == :new ? Guess.new(options) : Guess.create!(options)
  end
  private_class_method :make_for_test

end

class Revelation
  extend ModelFactory

  def self.make_for_test(new_or_create, padded_label, caller_options)
    now = Time.now
    options = {
      :revelation_text => padded_label + 'revelation text',
      :revealed_at => now,
      :added_at => now
    }
    if ! caller_options[:photo]
      photo_label = padded_label + 'revelation'
      options[:photo] =
        new_or_create == :new ? Photo.make(photo_label) : Photo.make!(photo_label)
    end
    options.merge! caller_options
    new_or_create == :new ? Revelation.new(options) : Revelation.create!(options)
  end
  private_class_method :make_for_test

end
