
SET foreign_key_checks = 0;

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
  CONSTRAINT `ezp_component_ibfk_2` FOREIGN KEY (`devtype`) REFERENCES `ezp_devtype` (`devtype`),
  CONSTRAINT `ezp_component_ibfk_3` FOREIGN KEY (`difficulty`) REFERENCES `ezp_difficulty` (`difficulty`),
  CONSTRAINT `ezp_component_ibfk_4` FOREIGN KEY (`vendor`, `package`) REFERENCES `ezp_package` (`vendor`, `package`),
  CONSTRAINT `ezp_component_ibfk_5` FOREIGN KEY (`developer`) REFERENCES `ezp_developer` (`developer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

