module MultiPhotoMapSupport
  extend ActiveSupport::Concern
  include PhotoMapSupport

  module ClassMethods

    def as_map_json(partial, bounds, photos)
      perturb_identical_locations photos
      {
        partial: partial,
        bounds: bounds,
        photos: photos.as_json(only: %i(id latitude longitude), methods: %i(color symbol))
      }
    end

    RADIUS = 0.000008

    def perturb_identical_locations(photos)
      perturbation_counts = {}
      photos.reverse_each do |photo|
        perturbation_count = perturbation_counts[[photo.latitude, photo.longitude]] || 0
        perturbation_counts[[photo.latitude, photo.longitude]] = perturbation_count + 1
        if perturbation_count > 0
          # See http://en.wikipedia.org/wiki/Involute#Examples
          angle = Math.sqrt(10 * perturbation_count) + Math::PI / 2
          cosine = Math.cos angle
          sine = Math.sin angle
          photo.longitude += RADIUS * (cosine + angle * sine)
          photo.latitude += RADIUS * (sine - angle * cosine)
        end
      end
    end

  end

end
