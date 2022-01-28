
SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `ezp_developer` (
  `developer` varchar(64) CHARACTER SET ascii NOT NULL,
  PRIMARY KEY (`developer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO `ezp_developer` VALUES
('Amber'),
('Dom'),
('Mark');

