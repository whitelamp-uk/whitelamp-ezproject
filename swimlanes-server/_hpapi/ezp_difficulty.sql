
SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `ezp_difficulty` (
  `difficulty` int(1) unsigned NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`difficulty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO `ezp_difficulty` (`difficulty`, `notes`) VALUES
(0, 'Undefined difficulty'),
(1, 'Trivial'),
(2, 'Straightforward'),
(3, 'Medium'),
(4, 'Challenging'),
(5, 'Very challenging');

