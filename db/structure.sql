-- MySQL dump 10.13  Distrib 5.1.68, for apple-darwin10.8.0 (i386)
--
-- Host: localhost    Database: gww_test
-- ------------------------------------------------------
-- Server version	5.1.68

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=847766 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flickr_updates`
--

DROP TABLE IF EXISTS `flickr_updates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `flickr_updates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `member_count` int(11) NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2449 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `geometry_columns`
--

DROP TABLE IF EXISTS `geometry_columns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `geometry_columns` (
  `F_TABLE_CATALOG` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `F_TABLE_SCHEMA` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `F_TABLE_NAME` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `F_GEOMETRY_COLUMN` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `COORD_DIMENSION` int(11) DEFAULT NULL,
  `SRID` int(11) DEFAULT NULL,
  `TYPE` varchar(256) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guesses`
--

DROP TABLE IF EXISTS `guesses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `guesses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `comment_text` text NOT NULL,
  `commented_at` datetime NOT NULL,
  `added_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_guesses_on_photo_id_and_person_id_and_comment_text` (`photo_id`,`person_id`,`comment_text`(255)),
  KEY `guesses_photo_id_fk` (`photo_id`),
  KEY `guesses_person_id_fk` (`person_id`),
  KEY `guesses_added_at_index` (`added_at`),
  KEY `guesses_commented_at_index` (`commented_at`),
  CONSTRAINT `guesses_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `guesses_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33780 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `people`
--

DROP TABLE IF EXISTS `people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `flickrid` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `pathalias` varchar(255) DEFAULT NULL,
  `comments_to_guess` decimal(7,4) DEFAULT NULL,
  `comments_per_post` decimal(7,4) NOT NULL DEFAULT '0.0000',
  `comments_to_be_guessed` decimal(7,4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `people_flickrid_unique` (`flickrid`),
  UNIQUE KEY `people_username_unique` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=1313 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `photos`
--

DROP TABLE IF EXISTS `photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `faves` int(11) NOT NULL,
  `other_user_comments` int(11) NOT NULL DEFAULT '0',
  `member_comments` int(11) NOT NULL DEFAULT '0',
  `member_questions` int(11) NOT NULL DEFAULT '0',
  `inferred_latitude` decimal(9,6) DEFAULT NULL,
  `inferred_longitude` decimal(9,6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `photos_flickrid_unique` (`flickrid`),
  KEY `photos_game_status_index` (`game_status`),
  KEY `photos_person_id_fk` (`person_id`),
  KEY `photos_dateadded_index` (`dateadded`),
  CONSTRAINT `photos_person_id_fk` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37323 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `revelations`
--

DROP TABLE IF EXISTS `revelations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `revelations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo_id` int(11) NOT NULL,
  `comment_text` text NOT NULL,
  `commented_at` datetime NOT NULL,
  `added_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `revelations_photo_id_unique` (`photo_id`),
  KEY `revelations_added_at_index` (`added_at`),
  CONSTRAINT `revelations_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=721 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `score_reports`
--

DROP TABLE IF EXISTS `score_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `score_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `previous_report_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `previous_report_id_fk` (`previous_report_id`),
  CONSTRAINT `previous_report_id_fk` FOREIGN KEY (`previous_report_id`) REFERENCES `score_reports` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=681 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `spatial_ref_sys`
--

DROP TABLE IF EXISTS `spatial_ref_sys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spatial_ref_sys` (
  `SRID` int(11) NOT NULL,
  `AUTH_NAME` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `AUTH_SRID` int(11) DEFAULT NULL,
  `SRTEXT` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stclines`
--

DROP TABLE IF EXISTS `stclines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stclines` (
  `OGR_FID` int(11) NOT NULL AUTO_INCREMENT,
  `SHAPE` geometry NOT NULL,
  `cnn` double(19,8) DEFAULT NULL,
  `street` varchar(29) COLLATE utf8_unicode_ci DEFAULT NULL,
  `st_type` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lf_fadd` double(19,8) DEFAULT NULL,
  `lf_toadd` double(19,8) DEFAULT NULL,
  `rt_fadd` double(19,8) DEFAULT NULL,
  `rt_toadd` double(19,8) DEFAULT NULL,
  `f_node_cnn` decimal(10,0) DEFAULT NULL,
  `t_node_cnn` decimal(10,0) DEFAULT NULL,
  `zip_code` varchar(9) COLLATE utf8_unicode_ci DEFAULT NULL,
  `district` varchar(3) COLLATE utf8_unicode_ci DEFAULT NULL,
  `accepted` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `jurisdicti` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `nhood` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `layer` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cnntext` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `streetname` varchar(36) COLLATE utf8_unicode_ci DEFAULT NULL,
  `classcode` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street_gc` varchar(29) COLLATE utf8_unicode_ci DEFAULT NULL,
  `streetn_gc` varchar(36) COLLATE utf8_unicode_ci DEFAULT NULL,
  UNIQUE KEY `OGR_FID` (`OGR_FID`),
  SPATIAL KEY `SHAPE` (`SHAPE`),
  KEY `stclines_street_index` (`street`),
  KEY `stclines_st_type_index` (`st_type`)
) ENGINE=MyISAM AUTO_INCREMENT=16353 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stintersections`
--

DROP TABLE IF EXISTS `stintersections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stintersections` (
  `OGR_FID` int(11) NOT NULL AUTO_INCREMENT,
  `SHAPE` geometry NOT NULL,
  `cnn` double(19,8) DEFAULT NULL,
  `st_name` varchar(29) COLLATE utf8_unicode_ci DEFAULT NULL,
  `st_type` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cnntext` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  UNIQUE KEY `OGR_FID` (`OGR_FID`),
  SPATIAL KEY `SHAPE` (`SHAPE`),
  KEY `stintersections_cnn_index` (`cnn`),
  KEY `stintersections_st_name_index` (`st_name`),
  KEY `stintersections_st_type_index` (`st_type`)
) ENGINE=MyISAM AUTO_INCREMENT=18666 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo_id` int(11) NOT NULL,
  `raw` varchar(255) COLLATE utf8_bin NOT NULL,
  `machine_tag` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tags_on_photo_id_and_raw` (`photo_id`,`raw`),
  CONSTRAINT `tags_photo_id_fk` FOREIGN KEY (`photo_id`) REFERENCES `photos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2211 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-05-21 22:03:13
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

INSERT INTO schema_migrations (version) VALUES ('20110406202855');

INSERT INTO schema_migrations (version) VALUES ('20110407194700');

INSERT INTO schema_migrations (version) VALUES ('20110421184330');

INSERT INTO schema_migrations (version) VALUES ('20110425211454');

INSERT INTO schema_migrations (version) VALUES ('20110425224807');

INSERT INTO schema_migrations (version) VALUES ('20110425230338');

INSERT INTO schema_migrations (version) VALUES ('20111008144025');

INSERT INTO schema_migrations (version) VALUES ('20111015174120');

INSERT INTO schema_migrations (version) VALUES ('20111016155721');

INSERT INTO schema_migrations (version) VALUES ('20140521042205');

INSERT INTO schema_migrations (version) VALUES ('20140521191000');

INSERT INTO schema_migrations (version) VALUES ('20140521234839');

INSERT INTO schema_migrations (version) VALUES ('20140522045551');

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

