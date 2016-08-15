FactoryGirl.define do
  factory :photo do
    association :person, strategy: :build
    flickrid { "1#{rand 10000000000}" }
    farm { rand(10).to_s }
    server { rand(9999).to_s }
    secret { rand(2**40).to_s 16 }
    dateadded { Time.now }
    lastupdate { Time.now }
    seen_at { Time.now }
    game_status 'unfound'
    views 0
    sequence(:title) { |n| "Title #{n}" }
    sequence(:description) { |n| "Description #{n}" }
    faves 0
  end

  [PeoplePhoto, PeopleShowPhoto, ScoreReportsPhoto, StatisticsPhoto, WheresiesPhoto].each do |specialist_class|
    factory_name = specialist_class.name.underscore
    factory factory_name, parent: :photo, class: specialist_class do
      association :person, factory: factory_name.sub(/photo$/, 'person'), strategy: :build
    end
  end

  factory :photos_photo, parent: :photo, class: PhotosPhoto
  factory :admin_photos_photo, parent: :photo, class: AdminPhotosPhoto
  factory :flickr_update_photo, parent: :photo, class: FlickrUpdatePhoto

  factory :guessed_photo, parent: :photo do
    game_status 'found'

    after(:create) do |photo|
      comment = create :comment, photo: photo
      create :guess, comment_text: comment.comment_text, photo: photo
    end

  end

end
