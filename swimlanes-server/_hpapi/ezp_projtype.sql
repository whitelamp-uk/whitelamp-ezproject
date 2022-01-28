
SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `ezp_projtype` (
  `projtype` varchar(64) CHARACTER SET ascii NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`projtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

