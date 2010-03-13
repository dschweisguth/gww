CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) NOT NULL,
  `flickrid` varchar(255) default NULL,
  `commented_at` datetime NOT NULL,
  `photo_id` int(11) NOT NULL,
  `comment_text` text,
  PRIMARY KEY  (`id`),
  KEY `comments_photo_id_index` (`photo_id`),
  CONSTRAINT `comments_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=321641 DEFAULT CHARSET=latin1;

CREATE TABLE `flickr_updates` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `completed_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=861 DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB AUTO_INCREMENT=22286 DEFAULT CHARSET=latin1;

CREATE TABLE `people` (
  `id` int(11) NOT NULL auto_increment,
  `flickrid` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `people_flickrid_unique` (`flickrid`),
  UNIQUE KEY `people_username_unique` (`username`),
  KEY `people_flickrid_index` (`flickrid`)
) ENGINE=InnoDB AUTO_INCREMENT=1093 DEFAULT CHARSET=latin1;

CREATE TABLE `photos` (
  `id` int(11) NOT NULL auto_increment,
  `flickrid` varchar(255) NOT NULL,
  `secret` varchar(255) NOT NULL,
  `server` varchar(255) NOT NULL,
  `dateadded` datetime NOT NULL,
  `lastupdate` datetime NOT NULL,
  `seen_at` datetime NOT NULL,
  `game_status` enum('unfound','unconfirmed','found','revealed') NOT NULL,
  `mapped` enum('true','false') NOT NULL,
  `person_id` int(11) NOT NULL,
  `farm` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `photos_flickrid_unique` (`flickrid`),
  KEY `photos_person_id_index` (`person_id`),
  KEY `photos_flickrid_index` (`flickrid`),
  KEY `photos_game_status_index` (`game_status`),
  CONSTRAINT `photos_person_id` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25318 DEFAULT CHARSET=latin1;

CREATE TABLE `revelations` (
  `id` int(11) NOT NULL auto_increment,
  `revelation_text` varchar(255) NOT NULL,
  `revealed_at` datetime NOT NULL,
  `photo_id` int(11) NOT NULL,
  `added_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `revelations_photo_id_unique` (`photo_id`),
  CONSTRAINT `revelations_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=371 DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (29)