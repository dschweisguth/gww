xml.instruct! :xml, version: "1.0", encoding: "utf-8"
xml.photos "updated_at" => @lasttime.to_i,
           "total" => @photos.length do
  @photos.each do |photo|
    photographer = photo.person
    xml.photo "posted_by" => photographer.username,
              "posted_id" => photographer.flickrid,
              "flickr_id" => photo.flickrid,
              "secret" => photo.secret,
              "server" => photo.server,
              "farm" => photo.farm,
              "added_on" => photo.dateadded.to_i,
              "last_updated" => photo.lastupdate.to_i,
              "status" => photo.game_status
  end
end
