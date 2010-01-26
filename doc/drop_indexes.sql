alter table photos drop index photos_person_id;
alter table guesses drop index guesses_person_id;
alter table photos drop index photos_flickrid;
alter table guesses drop index guesses_photo_id;
alter table people drop index people_flickrid;
