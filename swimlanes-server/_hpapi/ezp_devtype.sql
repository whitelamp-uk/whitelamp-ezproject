
SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `ezp_devtype` (
  `devtype` varchar(64) CHARACTER SET ascii NOT NULL,
  `notes` text NOT NULL,
  `skills` text NOT NULL,
  PRIMARY KEY (`devtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO `ezp_devtype` (`devtype`, `notes`, `skills`) VALUES
('HTML-INSERT', 'HTML5/CSS GUI insert (handlebars.js template)',  'HTML, Handlebars.js, partial understanding of client-side software pattern'),
('HTML-SCREEN', 'HTML5/CSS GUI screen (handlebars.js template)',  'HTML, Handlebars.js, partial understanding of client-side software pattern'),
('JS-FUNCTION', 'Javascript function(s).',  'Pure javascript with an emphasis on AJAX (asynchronous) and JSON notation.'),
('PHP-METHOD',  'Server-side PHP method', 'PHP server-side scripting.'),
('SQL-ROUTINE', 'MariaDB MySQL stored procedure.',  'SQL (mostly MariaDB implementation) with a strong emphasis on complex SELECT queries within stored procedures.');

