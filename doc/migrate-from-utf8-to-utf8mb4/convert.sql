alter database gww_dev character set utf8mb4 collate utf8mb4_unicode_ci;

alter table comments convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table comments modify comment_text text;

-- convert does nothing, not even set the default character set, since this table has
-- no character columns. Just set the default character set.
alter table flickr_updates default character set utf8mb4 collate utf8mb4_unicode_ci;

alter table guesses drop key index_guesses_on_photo_id_and_person_id_and_comment_text;
alter table guesses convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table guesses modify comment_text text;
alter table guesses add constraint index_guesses_on_photo_id_and_person_id_and_comment_text unique (photo_id, person_id, comment_text(191));

alter table people drop key people_flickrid_unique;
alter table people drop key people_username_unique;
alter table people convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table people add constraint people_flickrid_unique unique (flickrid(191));
alter table people add constraint people_username_unique unique (username(191));

alter table photos drop key photos_flickrid_unique;
alter table photos convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table photos modify description text;
alter table photos add constraint photos_flickrid_unique unique (flickrid(191));

alter table revelations convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table revelations modify comment_text text;

alter table schema_migrations drop key unique_schema_migrations;
alter table schema_migrations convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table schema_migrations add constraint unique_schema_migrations unique (version(191));

-- convert does nothing, not even set the default character set, since this table has
-- no character columns. Just set the default character set.
alter table score_reports default character set utf8mb4 collate utf8mb4_unicode_ci;

alter table tags drop foreign key tags_photo_id_fk;
alter table tags drop key index_tags_on_photo_id_and_raw;
alter table tags convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table tags add constraint index_tags_on_photo_id_and_raw unique (photo_id, raw(191));
alter table tags add constraint tags_photo_id_fk foreign key (photo_id) references photos (id);
