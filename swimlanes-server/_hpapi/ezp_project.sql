
SET foreign_key_checks = 0;

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

