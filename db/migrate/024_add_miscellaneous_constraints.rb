class AddMiscellaneousConstraints < ActiveRecord::Migration
  def self.up
    execute "alter table people add constraint people_flickrid_unique unique key (flickrid)"
    execute "alter table people add constraint people_username_unique unique key (username)"

    execute "alter table photos add constraint photos_flickrid_unique unique key (flickrid)"
    execute "alter table photos modify column game_status enum('unfound', 'unconfirmed', 'found', 'revealed') not null"
    execute "alter table photos modify column flickr_status enum('in pool', 'not in pool', 'missing') not null"
    execute "update photos set mapped = 'false' where mapped = ''"
    execute "alter table photos modify column mapped enum('true', 'false') not null"

    execute "alter table revelations add constraint revelations_photo_id_unique unique key (photo_id)"

  end

  def self.down
    execute "alter table people drop key people_flickrid_unique"
    execute "alter table people drop key people_username_unique"

    execute "alter table photos drop key photos_flickrid_unique"
    execute "alter table photos modify column game_status varchar(255) not null"
    execute "alter table photos modify column flickr_status varchar(255) not null"
    execute "alter table photos modify column mapped varchar(255) not null"
    execute "update photos set mapped = '' where flickr_status = 'missing'"

    execute "alter table revelations drop key revelations_photo_id_unique"

  end

end
