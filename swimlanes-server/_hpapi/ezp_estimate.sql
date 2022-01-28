
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


INSERT IGNORE INTO `ezp_estimate` (`devtype`, `difficulty`, `hours`) VALUES
('HTML-INSERT', 1,  1),
('HTML-INSERT', 2,  2),
('HTML-INSERT', 3,  3),
('HTML-INSERT', 4,  4),
('HTML-INSERT', 5,  5),
('HTML-SCREEN', 1,  1),
('HTML-SCREEN', 2,  2),
('HTML-SCREEN', 3,  3),
('HTML-SCREEN', 4,  5),
('HTML-SCREEN', 5,  8),
('JS-FUNCTION', 1,  1),
('JS-FUNCTION', 2,  3),
('JS-FUNCTION', 3,  6),
('JS-FUNCTION', 4,  10),
('JS-FUNCTION', 5,  20),
('PHP-METHOD',  1,  1),
('PHP-METHOD',  2,  3),
('PHP-METHOD',  3,  6),
('PHP-METHOD',  4,  12),
('PHP-METHOD',  5,  24),
('SQL-ROUTINE', 1,  2),
('SQL-ROUTINE', 2,  4),
('SQL-ROUTINE', 3,  6),
('SQL-ROUTINE', 4,  10),
('SQL-ROUTINE', 5,  20);

