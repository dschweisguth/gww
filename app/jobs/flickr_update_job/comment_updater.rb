module FlickrUpdateJob
  class CommentUpdater
    def self.update(photo)
      begin
        comments_xml = FlickrService.instance.photos_comments_get_list photo_id: photo.flickrid
        parsed_comments = comments_xml['comments'][0]['comment'] # nil if there are no comments and an array if there are
        if parsed_comments.nil?
          return
        end
        # Happens on photo 13744986833, on the comment supposedly containing a sad face emoji
        parsed_comments = parsed_comments.select { |c| c.key?('content') }
        if parsed_comments.any?
          attributes_hashes = parsed_comments.map do |parsed_comment|
            {
              flickrid: parsed_comment['author'],
              username: parsed_comment['authorname'],
              comment_text: parsed_comment['content'].scrub, # we got non-UTF8 text once
              commented_at: Time.at(parsed_comment['datecreate'].to_i).getutc
            }
          end
          photo.replace_comments attributes_hashes
        end
      rescue FlickrService::FlickrRequestFailedError => e
        # This happens when a photo has been removed from the group.
        Rails.logger.warn "Couldn't get comments for photo #{photo.id}, flickrid #{photo.flickrid}: FlickrService::FlickrRequestFailedError #{e.message}"
      end
    end
  end
end
