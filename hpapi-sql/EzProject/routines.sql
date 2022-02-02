
DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpSwimlanesStatuses`$$
CREATE PROCEDURE `ezpSwimlanesStatuses`(
)
BEGIN
  SELECT
    *
  FROM `ezp_status`
  ORDER BY `ordinal`
  ;
END$$


DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpSwimlanesSwimlanes`$$
CREATE PROCEDURE `ezpSwimlanesSwimlanes`(
  IN        `eml` VARCHAR(254) CHARSET ascii
 ,IN        `swimpoolCode` CHAR(4) CHARSET ascii
)
BEGIN
  SELECT
    `sl`.*
  FROM `ezp_user` AS `u`
  JOIN `ezp_swimmer` AS `sr`
    ON `sr`.`user`=`u`.`code`
  JOIN `ezp_swimpool` AS `sp`
    ON `sp`.`code`=`sr`.`swimpool`
   AND `sp`.`code`=swimpoolCode
  JOIN `ezp_swimlane` AS `sl`
    ON `sl`.`swimpool`=`sp`.`code`
  WHERE `u`.`email`=eml
  ;
END$$


DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpSwimlanesSwimpools`$$
CREATE PROCEDURE `ezpSwimlanesSwimpools`(
)
BEGIN
  SELECT
    *
  FROM `ezp_swimpool` AS `p`
  ;
END$$


DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpSwimlanesSwims`$$
CREATE PROCEDURE `ezpSwimlanesSwims`(
  IN        `swimpoolCode` CHAR(4) CHARSET ascii
 ,IN        `swimlaneCode` CHAR(4) CHARSET ascii
 ,IN        `statusCode` CHAR(4) CHARSET ascii
)
BEGIN
  SELECT
    `sm`.*
  FROM `ezp_swimlane` AS `sl`
  JOIN `ezp_swim` AS `sm`
    ON `sm`.`swimpool`=`sl`.`swimpool`
   AND `sm`.`swimlane`=`sl`.`code`
   AND `sm`.`status`=statusCode
  WHERE `sl`.`swimpool`=swimpoolCode
    AND `sl`.`code`=swimlaneCode
  ;
END$$


DELIMITER ;

