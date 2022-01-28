
SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `ezp_timesheet` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `day` date NOT NULL,
  `hours` decimal(5,2) unsigned NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=985 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

