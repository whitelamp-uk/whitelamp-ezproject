
SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `ezp_estimate` (
  `devtype` varchar(64) CHARACTER SET ascii NOT NULL,
  `difficulty` int(1) unsigned NOT NULL,
  `hours` int(4) unsigned NOT NULL,
  PRIMARY KEY (`devtype`,`difficulty`),
  KEY `estimate_Difficulty` (`difficulty`),
  CONSTRAINT `ezp_estimate_ibfk_1` FOREIGN KEY (`difficulty`) REFERENCES `ezp_difficulty` (`difficulty`),
  CONSTRAINT `ezp_estimate_ibfk_2` FOREIGN KEY (`devtype`) REFERENCES `ezp_devtype` (`devtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


