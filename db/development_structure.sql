CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) NOT NULL default '',
  `userid` varchar(255) NOT NULL default '',
  `commented_at` datetime NOT NULL default '0000-00-00 00:00:00',
  `photo_id` int(11) NOT NULL default '0',
  `comment_text` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=316397 DEFAULT CHARSET=latin1;

CREATE TABLE `flickr_updates` (
  `id` int(11) NOT NULL auto_increment,
  `updated_at` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=841 DEFAULT CHARSET=latin1;

CREATE TABLE `guesses` (
  `id` int(11) NOT NULL auto_increment,
  `guessed_at` datetime NOT NULL default '0000-00-00 00:00:00',
  `photo_id` int(11) NOT NULL default '0',
  `person_id` int(11) NOT NULL default '0',
  `guess_text` text,
  `added_at` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `guesses_person_id_index` (`person_id`),
  KEY `guesses_photo_id_index` (`photo_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21955 DEFAULT CHARSET=latin1;

CREATE TABLE `people` (
  `id` int(11) NOT NULL auto_increment,
  `flickrid` varchar(255) NOT NULL default '',
  `iconserver` varchar(255) NOT NULL default '',
  `username` varchar(255) NOT NULL default '',
  `photosurl` varchar(255) NOT NULL default '',
  `flickr_status` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`),
  KEY `people_flickrid_index` (`flickrid`)
) ENGINE=InnoDB AUTO_INCREMENT=1083 DEFAULT CHARSET=latin1;

CREATE TABLE `photos` (
  `id` int(11) NOT NULL auto_increment,
  `flickrid` varchar(255) NOT NULL default '',
  `secret` varchar(255) NOT NULL default '',
  `server` varchar(255) NOT NULL default '',
  `dateadded` datetime NOT NULL default '0000-00-00 00:00:00',
  `lastupdate` datetime NOT NULL default '0000-00-00 00:00:00',
  `seen_at` datetime NOT NULL default '0000-00-00 00:00:00',
  `game_status` varchar(255) NOT NULL default '',
  `flickr_status` varchar(255) NOT NULL default '',
  `mapped` varchar(255) NOT NULL default '',
  `person_id` int(11) NOT NULL default '0',
  `farm` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`),
  KEY `photos_person_id_index` (`person_id`),
  KEY `photos_flickrid_index` (`flickrid`),
  KEY `photos_person_id_dateadded` (`person_id`,`dateadded`)
) ENGINE=InnoDB AUTO_INCREMENT=24912 DEFAULT CHARSET=latin1;

CREATE TABLE `revelations` (
  `id` int(11) NOT NULL auto_increment,
  `revelation_text` varchar(255) NOT NULL default '',
  `revealed_at` datetime NOT NULL default '0000-00-00 00:00:00',
  `photo_id` int(11) NOT NULL default '0',
  `person_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=372 DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (12)