
SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `ezp_package` (
  `vendor` varchar(64) CHARACTER SET ascii NOT NULL,
  `package` varchar(64) CHARACTER SET ascii NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`vendor`,`package`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

