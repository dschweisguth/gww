module ModelFactory
  def make(label = '', options = {})
    do_make :new, label, options
  end

  def make!(label = '', options = {})
    do_make :create!, label, options
  end

  def do_make(new_or_create, label, caller_options)
    if label.is_a? Hash
      caller_options = label
      label = ''
    end
    padded_label = label.to_s
    if ! padded_label.empty?
      padded_label += '_'
    end
    options = options new_or_create, padded_label, caller_options
    send new_or_create, options
  end
  private :do_make

end

class FlickrUpdate
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.options(new_or_create, padded_label, caller_options)
    options = { :member_count => 0 }
    if new_or_create == :new && ! caller_options[:created_at]
      options[:created_at] = Time.now
    end
    options.merge! caller_options
    options
  end
  private_class_method :options

end

class Person
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.options(new_or_create, padded_label, caller_options)
    options = {
      :flickrid => padded_label + 'person_flickrid',
      :username => padded_label + 'username'
    }
    options.merge! caller_options
    options
  end
  private_class_method :options

end

class Photo
  extend ModelFactory

  def self.options(new_or_create, padded_label, caller_options)
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
    options
  end
  private_class_method :options

end

class Comment
  extend ModelFactory

  def self.options(new_or_create, padded_label, caller_options)
    options = {
      :flickrid => padded_label + 'commenter_flickrid',
      :username => padded_label + 'commenter_username',
      :comment_text => padded_label + 'comment text',
      :commented_at => Time.now
    }
    if ! caller_options[:photo]
      photo_label = padded_label + 'commented_photo'
      options[:photo] =
        new_or_create == :new ? Photo.make(photo_label) : Photo.make!(photo_label)
    end
    options.merge! caller_options
    options
  end
  private_class_method :options

end

class Guess
  extend ModelFactory

  def self.options(new_or_create, padded_label, caller_options)
    now = Time.now
    options = {
      :guess_text => padded_label + 'guess text',
      :guessed_at => now,
      :added_at => now
    }
    if ! caller_options[:photo]
      photo_label = padded_label + 'guessed_photo'
      options[:photo] =
        new_or_create == :new ? Photo.make(photo_label) : Photo.make!(photo_label)
    end
    if ! caller_options[:person]
      person_label = padded_label + 'guesser'
      options[:person] =
        new_or_create == :new ? Person.make(person_label) : Person.make!(person_label)
    end
    options.merge! caller_options
    options
  end
  private_class_method :options

end

class Revelation
  extend ModelFactory

  def self.options(new_or_create, padded_label, caller_options)
    now = Time.now
    options = {
      :revelation_text => padded_label + 'revelation text',
      :revealed_at => now,
      :added_at => now
    }
    if ! caller_options[:photo]
      photo_label = padded_label + 'revealed_photo'
      options[:photo] =
        new_or_create == :new ? Photo.make(photo_label) : Photo.make!(photo_label)
    end
    options.merge! caller_options
    options
  end
  private_class_method :options

end
