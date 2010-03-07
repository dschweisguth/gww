CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) NOT NULL,
  `userid` varchar(255) NOT NULL,
  `commented_at` datetime NOT NULL,
  `photo_id` int(11) NOT NULL,
  `comment_text` text,
  PRIMARY KEY  (`id`),
  KEY `comments_photo_id_index` (`photo_id`),
  CONSTRAINT `comments_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=323760 DEFAULT CHARSET=latin1;

CREATE TABLE `flickr_updates` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `completed_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=876 DEFAULT CHARSET=latin1;

CREATE TABLE `guesses` (
  `id` int(11) NOT NULL auto_increment,
  `guessed_at` datetime NOT NULL,
  `photo_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `guess_text` text,
  `added_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `guesses_person_id_index` (`person_id`),
  KEY `guesses_photo_id_index` (`photo_id`),
  CONSTRAINT `guesses_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `guesses_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22432 DEFAULT CHARSET=latin1;

CREATE TABLE `people` (
  `id` int(11) NOT NULL auto_increment,
  `flickrid` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `people_flickrid_index` (`flickrid`)
) ENGINE=InnoDB AUTO_INCREMENT=1092 DEFAULT CHARSET=latin1;

CREATE TABLE `photos` (
  `id` int(11) NOT NULL auto_increment,
  `flickrid` varchar(255) NOT NULL,
  `secret` varchar(255) NOT NULL,
  `server` varchar(255) NOT NULL,
  `dateadded` datetime NOT NULL,
  `lastupdate` datetime NOT NULL,
  `seen_at` datetime NOT NULL,
  `game_status` varchar(255) NOT NULL,
  `flickr_status` varchar(255) NOT NULL,
  `mapped` varchar(255) NOT NULL,
  `person_id` int(11) NOT NULL,
  `farm` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `photos_person_id_index` (`person_id`),
  KEY `photos_flickrid_index` (`flickrid`),
  KEY `photos_game_status_index` (`game_status`)
) ENGINE=InnoDB AUTO_INCREMENT=25233 DEFAULT CHARSET=latin1;

CREATE TABLE `revelations` (
  `id` int(11) NOT NULL auto_increment,
  `revelation_text` varchar(255) NOT NULL,
  `revealed_at` datetime NOT NULL,
  `photo_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `added_at` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `revelations_photo_id_fk` (`photo_id`),
  KEY `revelations_person_id_fk` (`person_id`),
  CONSTRAINT `revelations_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `revelations_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=374 DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (22)