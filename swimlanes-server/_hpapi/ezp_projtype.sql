
SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `ezp_projtype` (
  `projtype` varchar(64) CHARACTER SET ascii NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`projtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO `ezp_projtype` (`projtype`, `notes`) VALUES
('des-and-dev', 'Design and development of new product'),
('housekeeping',  'Set up of development system requirements'),
('maintenance', 'Ongoing support of existing product'),
('other', 'General purpose or uncategorisable'),
('techsupport', 'Provision of system technical support');

