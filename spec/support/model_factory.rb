module ModelFactory
  def make(label = '', caller_attrs = {})
    method = construction_method

    if label.is_a? Hash
      caller_attrs = label
      label = ''
    end
    caller_attrs = caller_attrs.clone

    # In model specs and Cucumber features, we use create! and let ActiveRecord choose an id.
    # When testing other layers, we use new, which creates an object with a nil id.
    # We want to be able to assign an id to our model object, but ActiveRecord prevents us
    # from doing so as an argument to new. Instead, save it so we can set it later.
    id = caller_attrs[:id]
    if id
      if method != :new
        raise ArgumentError, "Can't specify :id for an object which is to be create!d in the database"
      end
      caller_attrs.delete :id
    else
      if method == :new
        id = 0
      end
    end

    attrs = attrs method, label, caller_attrs
    attrs.merge! caller_attrs

    instance = send method, attrs

    if id
      instance.id = id
    end

    instance
  end

  def construction_method
    caller.find { |line| line =~ /\/spec\/models\/|\/features\/step_definitions\// } ? :create! : :new
  end

  def affix(label, value)
    label = label.to_s
    label.empty? ? value : label + '_' + value
  end

end

class FlickrUpdate
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  private_class_method def self.attrs(method, label, caller_attrs)
    attrs = { member_count: 0 }
    if method == :new && ! caller_attrs[:created_at]
      attrs[:created_at] = Time.now
    end
    attrs
  end

end

class ScoreReport
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  private_class_method def self.attrs(method, label, caller_attrs)
    attrs = {}
    if method == :new && ! caller_attrs[:created_at]
      attrs[:created_at] = Time.now
    end
    attrs
  end

end

class Person
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  private_class_method def self.attrs(method, label, caller_attrs)
    {
      flickrid: affix(label, 'person_flickrid'),
      username: affix(label, 'username'),
      comments_per_post: 0
    }
  end

end

class Photo
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  private_class_method def self.attrs(method, label, caller_attrs)
    now = Time.now
    attrs = {
      flickrid: affix(label, 'photo_flickrid'),
      farm: '0',
      server: 'server',
      secret: 'secret',
      dateadded: now,
      lastupdate: now,
      seen_at: now,
      game_status: 'unfound',
      views: 0,
      title: 'Title',
      description: 'Description',
      faves: 0
    }
    if ! caller_attrs[:person]
      attrs[:person] = Person.make affix(label, 'poster')
    end
    attrs
  end

end

class Comment
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  private_class_method def self.attrs(method, label, caller_attrs)
    attrs = {
      flickrid: affix(label, 'commenter_flickrid'),
      username: affix(label, 'commenter_username'),
      comment_text: affix(label, 'comment text'),
      commented_at: Time.now
    }
    if ! caller_attrs[:photo]
      attrs[:photo] = Photo.make affix(label, 'commented_photo')
    end
    attrs
  end

end

class Guess
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  private_class_method def self.attrs(method, label, caller_attrs)
    now = Time.now
    attrs = {
      comment_text: affix(label, 'guess text'),
      commented_at: now,
      added_at: now
    }
    if ! caller_attrs[:photo]
      attrs[:photo] = Photo.make affix(label, 'guessed_photo'), game_status: 'found'
    end
    if ! caller_attrs[:person]
      attrs[:person] = Person.make affix(label, 'guesser')
    end
    attrs
  end

end

class Revelation
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  private_class_method def self.attrs(method, label, caller_attrs)
    now = Time.now
    attrs = {
      comment_text: affix(label, 'revelation text'),
      commented_at: now,
      added_at: now
    }
    if ! caller_attrs[:photo]
      attrs[:photo] = Photo.make affix(label, 'revealed_photo'), game_status: 'revealed'
    end
    attrs
  end

end
