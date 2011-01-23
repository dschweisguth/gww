module Admin::PhotosHelper
  def pluralize_word_only(count, singular)
    count == 1 ? singular : ActiveSupport::Inflector.pluralize(singular)
  end
end
