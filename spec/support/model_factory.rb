module ModelFactory
  def make(label = '', caller_options = {})
    method = construction_method

    if label.is_a? Hash
      caller_options = label
      label = ''
    end
    caller_options = caller_options.clone

    padded_label = label.to_s
    if ! padded_label.empty?
      padded_label += '_'
    end

    # When testing layers above the model layer, we always use :new. We want
    # model objects to have @ids, but ActiveRecord prevents us from setting
    # that attribute at creation time, so save it so we can set it later.
    # When testing the model layer, we always use :create! and let ActiveRecord manage @id.
    id = caller_options[:id]
    if id
      if method != :new
        raise ArgumentError, "Can't specify :id for an object which is to be create!d in the database"
      end
      caller_options.delete :id
    else
      if method == :new
        id = 0
      end
    end

    options = options method, padded_label, caller_options
    options.merge! caller_options

    instance = send method, options

    if id
      instance.id = id
    end

    instance
  end

  def construction_method
    caller.find { |line| line =~ /\/spec\/models\// }.nil? ? :new : :create!
  end

end

class FlickrUpdate
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.options(calling_method, padded_label, caller_options)
    options = { :member_count => 0 }
    if calling_method == :new && ! caller_options[:created_at]
      options[:created_at] = Time.now
    end
    options
  end
  private_class_method :options

end

class Person
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.options(calling_method, padded_label, caller_options)
    {
      :flickrid => padded_label + 'person_flickrid',
      :username => padded_label + 'username'
    }
  end
  private_class_method :options

end

class Photo
  extend ModelFactory

  def self.options(calling_method, padded_label, caller_options)
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
      options[:person] = Person.make padded_label + 'poster'
    end
    options
  end
  private_class_method :options

end

class Comment
  extend ModelFactory

  def self.options(calling_method, padded_label, caller_options)
    options = {
      :flickrid => padded_label + 'commenter_flickrid',
      :username => padded_label + 'commenter_username',
      :comment_text => padded_label + 'comment text',
      :commented_at => Time.now
    }
    if ! caller_options[:photo]
      options[:photo] = Photo.make padded_label + 'commented_photo'
    end
    options
  end
  private_class_method :options

end

class Guess
  extend ModelFactory

  def self.options(calling_method, padded_label, caller_options)
    now = Time.now
    options = {
      :guess_text => padded_label + 'guess text',
      :guessed_at => now,
      :added_at => now
    }
    if ! caller_options[:photo]
      options[:photo] = Photo.make padded_label + 'guessed_photo'
    end
    if ! caller_options[:person]
      options[:person] = Person.make padded_label + 'guesser'
    end
    options
  end
  private_class_method :options

end

class Revelation
  extend ModelFactory

  def self.options(calling_method, padded_label, caller_options)
    now = Time.now
    options = {
      :revelation_text => padded_label + 'revelation text',
      :revealed_at => now,
      :added_at => now
    }
    if ! caller_options[:photo]
      options[:photo] = Photo.make padded_label + 'revealed_photo'
    end
    options
  end
  private_class_method :options

end
