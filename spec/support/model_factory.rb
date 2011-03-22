module ModelFactory
  def make(label = '', caller_attrs = {})
    method = construction_method

    if label.is_a? Hash
      caller_attrs = label
      label = ''
    end
    caller_attrs = caller_attrs.clone

    # When testing layers above the model layer, we always use :new. We want
    # model objects to have @ids, but ActiveRecord prevents us from setting
    # that attribute at creation time, so save it so we can set it later.
    # When testing the model layer, we always use :create! and let ActiveRecord manage @id.
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
    caller.find { |line| line =~ /\/spec\/models\// }.nil? ? :new : :create!
  end

  def affix(label, value)
    label = label.to_s
    label.empty? ? value : label + '_' + value
  end

end

class FlickrUpdate
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.attrs(method, label, caller_attrs)
    attrs = { :member_count => 0 }
    if method == :new && ! caller_attrs[:created_at]
      attrs[:created_at] = Time.now
    end
    attrs
  end
  private_class_method :attrs

end

class ScoreReport
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.attrs(method, label, caller_attrs)
    attrs = {}
    if method == :new && ! caller_attrs[:created_at]
      attrs[:created_at] = Time.now
    end
    attrs
  end
  private_class_method :attrs

end

class Person
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.attrs(method, label, caller_attrs)
    {
      :flickrid => affix(label, 'person_flickrid'),
      :username => affix(label, 'username')
    }
  end
  private_class_method :attrs

end

class Photo
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.attrs(method, label, caller_attrs)
    now = Time.now
    attrs = {
      :flickrid => affix(label, 'photo_flickrid'),
      :farm => '0',
      :server => 'server',
      :secret => 'secret',
      :dateadded => now,
      :lastupdate => now,
      :seen_at => now,
      :game_status => 'unfound',
      :views => 0
    }
    if ! caller_attrs[:person]
      attrs[:person] = Person.make affix(label, 'poster')
    end
    attrs
  end
  private_class_method :attrs

end

class Comment
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.attrs(method, label, caller_attrs)
    attrs = {
      :flickrid => affix(label, 'commenter_flickrid'),
      :username => affix(label, 'commenter_username'),
      :comment_text => affix(label, 'comment text'),
      :commented_at => Time.now
    }
    if ! caller_attrs[:photo]
      attrs[:photo] = Photo.make affix(label, 'commented_photo')
    end
    attrs
  end
  private_class_method :attrs

end

class Guess
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.attrs(method, label, caller_attrs)
    now = Time.now
    attrs = {
      :guess_text => affix(label, 'guess text'),
      :guessed_at => now,
      :added_at => now
    }
    if ! caller_attrs[:photo]
      attrs[:photo] = Photo.make affix(label, 'guessed_photo'), :game_status => 'found'
    end
    if ! caller_attrs[:person]
      attrs[:person] = Person.make affix(label, 'guesser')
    end
    attrs
  end
  private_class_method :attrs

end

class Revelation
  extend ModelFactory

  #noinspection RubyUnusedLocalVariable
  def self.attrs(method, label, caller_attrs)
    now = Time.now
    attrs = {
      :revelation_text => affix(label, 'revelation text'),
      :revealed_at => now,
      :added_at => now
    }
    if ! caller_attrs[:photo]
      attrs[:photo] = Photo.make affix(label, 'revealed_photo'), :game_status => 'revealed'
    end
    attrs
  end
  private_class_method :attrs

end
