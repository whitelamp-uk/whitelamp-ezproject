-- Adminer 4.7.5 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS `_readme` (
  `project` char(64),
  `location` varchar(255) NOT NULL,
  PRIMARY KEY (`project`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii;

CREATE TABLE IF NOT EXISTS `ezp_component` (
  `vendor` varchar(64) CHARACTER SET ascii NOT NULL,
  `package` varchar(64) CHARACTER SET ascii NOT NULL,
  `handle` varchar(64) CHARACTER SET ascii NOT NULL,
  `devtype` varchar(64) CHARACTER SET ascii NOT NULL,
  `difficulty` int(1) unsigned NOT NULL DEFAULT '3',
  `required_by` date DEFAULT NULL,
  `developer` varchar(64) CHARACTER SET ascii DEFAULT NULL,
  `progress_pct` int(4) unsigned NOT NULL DEFAULT '0',
  `notes` text NOT NULL,
  PRIMARY KEY (`vendor`,`package`,`handle`),
  KEY `developer` (`developer`),
  KEY `vendor` (`vendor`),
  KEY `devtype` (`devtype`),
  KEY `difficulty` (`difficulty`),
  KEY `package` (`vendor`,`package`),
  CONSTRAINT `ezp_component_ibfk_1` FOREIGN KEY (`devtype`) REFERENCES `ezp_devtype` (`devtype`),
  CONSTRAINT `ezp_component_ibfk_2` FOREIGN KEY (`difficulty`) REFERENCES `ezp_difficulty` (`difficulty`),
  CONSTRAINT `ezp_component_ibfk_3` FOREIGN KEY (`vendor`, `package`) REFERENCES `ezp_package` (`vendor`, `package`),
  CONSTRAINT `ezp_component_ibfk_4` FOREIGN KEY (`developer`) REFERENCES `ezp_developer` (`developer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `ezp_developer` (
  `developer` varchar(64) CHARACTER SET ascii NOT NULL,
  PRIMARY KEY (`developer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `ezp_devtype` (
  `devtype` varchar(64) CHARACTER SET ascii NOT NULL,
  `notes` text NOT NULL,
  `skills` text NOT NULL,
  PRIMARY KEY (`devtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `ezp_difficulty` (
  `difficulty` int(1) unsigned NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`difficulty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `ezp_estimate` (
  `devtype` varchar(64) CHARACTER SET ascii NOT NULL,
  `difficulty` int(1) unsigned NOT NULL,
  `hours` int(4) unsigned NOT NULL,
  PRIMARY KEY (`devtype`,`difficulty`),
  KEY `estimate_Difficulty` (`difficulty`),
  CONSTRAINT `ezp_estimate_ibfk_1` FOREIGN KEY (`difficulty`) REFERENCES `ezp_difficulty` (`difficulty`),
  CONSTRAINT `ezp_estimate_ibfk_2` FOREIGN KEY (`devtype`) REFERENCES `ezp_devtype` (`devtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `ezp_package` (
  `vendor` varchar(64) CHARACTER SET ascii NOT NULL,
  `package` varchar(64) CHARACTER SET ascii NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`vendor`,`package`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `ezp_projcostcentre` (
  `projcostcentre` varchar(64) CHARACTER SET ascii NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`projcostcentre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `ezp_project` (
  `project` varchar(64) CHARACTER SET ascii NOT NULL,
  `projgroup` varchar(64) CHARACTER SET ascii NOT NULL,
  `projtype` varchar(64) CHARACTER SET ascii NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`project`),
  KEY `projtype` (`projtype`),
  CONSTRAINT `ezp_project_ibfk_1` FOREIGN KEY (`projtype`) REFERENCES `ezp_projtype` (`projtype`)
  CONSTRAINT `ezp_project_ibfk_2` FOREIGN KEY (`projcostcentre`) REFERENCES `ezp_projcostcentre` (`projcostcentre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `ezp_projtype` (
  `projtype` varchar(64) CHARACTER SET ascii NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`projtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `ezp_timesheet` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `day` date NOT NULL,
  `hours` decimal(3,1) unsigned NOT NULL,
  `developer` varchar(64) CHARACTER SET ascii NOT NULL,
  `project` varchar(64) CHARACTER SET ascii NOT NULL,
  `comment` varchar(255) NOT NULL,
  `vendor` varchar(64) CHARACTER SET ascii DEFAULT NULL,
  `package` varchar(64) CHARACTER SET ascii DEFAULT NULL,
  `handle` varchar(64) CHARACTER SET ascii DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `developer` (`developer`),
  KEY `component` (`vendor`,`package`,`handle`),
  KEY `project` (`project`),
  CONSTRAINT `ezp_timesheet_ibfk_2` FOREIGN KEY (`developer`) REFERENCES `ezp_developer` (`developer`),
  CONSTRAINT `ezp_timesheet_ibfk_3` FOREIGN KEY (`vendor`, `package`, `handle`) REFERENCES `ezp_component` (`vendor`, `package`, `handle`),
  CONSTRAINT `ezp_timesheet_ibfk_4` FOREIGN KEY (`project`) REFERENCES `ezp_project` (`project`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- 2020-01-02 17:05:47
