
SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `ezp_projcostcentre` (
  `projcostcentre` varchar(64) CHARACTER SET ascii NOT NULL,
  `notes` text NOT NULL,
  PRIMARY KEY (`projcostcentre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

