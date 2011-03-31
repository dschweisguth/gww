CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo_id` int(11) NOT NULL,
  `flickrid` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `comment_text` text NOT NULL,
  `commented_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `comments_photo_id_fk` (`photo_id`),
  CONSTRAINT `comments_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=380866 DEFAULT CHARSET=utf8;

CREATE TABLE `flickr_updates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `member_count` int(11) NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1266 DEFAULT CHARSET=utf8;

CREATE TABLE `guesses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `comment_text` text NOT NULL,
  `commented_at` datetime NOT NULL,
  `added_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `guesses_photo_id_fk` (`photo_id`),
  KEY `guesses_person_id_fk` (`person_id`),
  CONSTRAINT `guesses_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `guesses_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26618 DEFAULT CHARSET=utf8;

CREATE TABLE `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `flickrid` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `people_flickrid_unique` (`flickrid`),
  UNIQUE KEY `people_username_unique` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=1203 DEFAULT CHARSET=utf8;

CREATE TABLE `photos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL,
  `flickrid` varchar(255) NOT NULL,
  `farm` varchar(255) NOT NULL,
  `server` varchar(255) NOT NULL,
  `secret` varchar(255) NOT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `accuracy` int(2) DEFAULT NULL,
  `dateadded` datetime NOT NULL,
  `lastupdate` datetime NOT NULL,
  `seen_at` datetime NOT NULL,
  `game_status` enum('unfound','unconfirmed','found','revealed') NOT NULL,
  `views` int(11) NOT NULL,
  `member_comments` int(11) NOT NULL DEFAULT '0',
  `member_questions` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `photos_flickrid_unique` (`flickrid`),
  KEY `photos_game_status_index` (`game_status`),
  KEY `photos_person_id_fk` (`person_id`),
  CONSTRAINT `photos_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30286 DEFAULT CHARSET=utf8;

CREATE TABLE `revelations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo_id` int(11) NOT NULL,
  `comment_text` text NOT NULL,
  `commented_at` datetime NOT NULL,
  `added_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `revelations_photo_id_unique` (`photo_id`),
  CONSTRAINT `revelations_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=461 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `score_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `previous_report_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `previous_report_id_fk` (`previous_report_id`),
  CONSTRAINT `previous_report_id_fk` FOREIGN KEY (`previous_report_id`) REFERENCES `score_reports` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=567 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20100612165811');

INSERT INTO schema_migrations (version) VALUES ('20100615121254');

INSERT INTO schema_migrations (version) VALUES ('20110120174937');

INSERT INTO schema_migrations (version) VALUES ('20110129012304');

INSERT INTO schema_migrations (version) VALUES ('20110202170911');

INSERT INTO schema_migrations (version) VALUES ('20110303010929');

INSERT INTO schema_migrations (version) VALUES ('20110305155922');

INSERT INTO schema_migrations (version) VALUES ('20110307195223');

INSERT INTO schema_migrations (version) VALUES ('20110322133223');

INSERT INTO schema_migrations (version) VALUES ('20110331171121');

INSERT INTO schema_migrations (version) VALUES ('20110331175257');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('36');

INSERT INTO schema_migrations (version) VALUES ('37');

INSERT INTO schema_migrations (version) VALUES ('38');