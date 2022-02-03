
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
    `sl`.`id`
   ,`sp`.`code` AS `swimpool`
   ,`sl`.`code`
   ,`sl`.`name`
   ,`sl`.`created`
   ,`sl`.`updated`
   ,GROUP_CONCAT(
      CONCAT(`swims`.`status`,':',`swims`.`quantity`)
    ) AS `swims`
  FROM `ezp_user` AS `u`
  JOIN `ezp_swimmer` AS `sr`
    ON `sr`.`user`=`u`.`code`
  JOIN `ezp_swimpool` AS `sp`
    ON `sp`.`code`=`sr`.`swimpool`
   AND `sp`.`code`=swimpoolCode
  LEFT JOIN `ezp_swimlane` AS `sl`
    ON `sl`.`swimpool`=`sp`.`code`
  LEFT JOIN (
    SELECT
      `swimpool`
     ,`swimlane`
     ,`status`
     ,COUNT(`id`) AS `quantity`
    FROM `ezp_swim`
    GROUP BY `swimpool`,`swimlane`,`status`
  ) AS `swims`
    ON `swims`.`swimpool`=`sl`.`swimpool`
   AND `swims`.`swimlane`=`sl`.`code`
  WHERE `u`.`email`=eml
  GROUP BY `sp`.`code`,`sl`.`code`
  ;
END$$


DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpSwimlanesSwimpools`$$
CREATE PROCEDURE `ezpSwimlanesSwimpools`(
)
BEGIN
  SELECT
    `sp`.*
   ,GROUP_CONCAT(DISTINCT CONCAT(`ur`.`code`,'::',`ur`.`email`) SEPARATOR ';;') AS `swimmers`
  FROM `ezp_swimpool` AS `sp`
  LEFT JOIN `ezp_swimmer` AS `sr`
         ON `sr`.`swimpool`=`sp`.`code`
  LEFT JOIN `ezp_user` AS `ur`
         ON `ur`.`code`=`sr`.`user`
  GROUP BY `sp`.`code`
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

