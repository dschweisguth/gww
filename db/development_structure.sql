CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `photo_id` int(11) NOT NULL default '0',
  `flickrid` varchar(255) NOT NULL default '',
  `username` varchar(255) NOT NULL default '',
  `comment_text` text NOT NULL,
  `commented_at` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `comments_photo_id_fk` (`photo_id`),
  CONSTRAINT `comments_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=330229 DEFAULT CHARSET=latin1;

CREATE TABLE `flickr_updates` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL default '0000-00-00 00:00:00',
  `member_count` int(11) NOT NULL,
  `completed_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=908 DEFAULT CHARSET=latin1;

CREATE TABLE `guesses` (
  `id` int(11) NOT NULL auto_increment,
  `photo_id` int(11) NOT NULL default '0',
  `person_id` int(11) NOT NULL default '0',
  `guess_text` text NOT NULL,
  `guessed_at` datetime NOT NULL default '0000-00-00 00:00:00',
  `added_at` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `guesses_photo_id_fk` (`photo_id`),
  KEY `guesses_person_id_fk` (`person_id`),
  CONSTRAINT `guesses_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `guesses_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22856 DEFAULT CHARSET=latin1;

CREATE TABLE `people` (
  `id` int(11) NOT NULL auto_increment,
  `flickrid` varchar(255) NOT NULL default '',
  `username` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `people_flickrid_unique` (`flickrid`),
  UNIQUE KEY `people_username_unique` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=1099 DEFAULT CHARSET=latin1;

CREATE TABLE `photos` (
  `id` int(11) NOT NULL auto_increment,
  `person_id` int(11) NOT NULL default '0',
  `flickrid` varchar(255) NOT NULL default '',
  `farm` varchar(255) NOT NULL default '',
  `server` varchar(255) NOT NULL default '',
  `secret` varchar(255) NOT NULL default '',
  `dateadded` datetime NOT NULL default '0000-00-00 00:00:00',
  `mapped` enum('false','true') NOT NULL default 'false',
  `lastupdate` datetime NOT NULL default '0000-00-00 00:00:00',
  `seen_at` datetime NOT NULL default '0000-00-00 00:00:00',
  `game_status` enum('unfound','unconfirmed','found','revealed') NOT NULL default 'unfound',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `photos_flickrid_unique` (`flickrid`),
  KEY `photos_game_status_index` (`game_status`),
  KEY `photos_person_id_fk` (`person_id`),
  CONSTRAINT `photos_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25750 DEFAULT CHARSET=latin1;

CREATE TABLE `revelations` (
  `id` int(11) NOT NULL auto_increment,
  `photo_id` int(11) NOT NULL default '0',
  `revelation_text` varchar(255) NOT NULL default '',
  `revealed_at` datetime NOT NULL default '0000-00-00 00:00:00',
  `added_at` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `revelations_photo_id_unique` (`photo_id`),
  CONSTRAINT `revelations_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=379 DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (38)