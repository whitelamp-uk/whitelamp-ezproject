
DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpSwimlanesDeparts`$$
CREATE PROCEDURE `ezpSwimlanesDeparts`(
  IN        `swimpoolCode` CHAR(4) CHARSET ascii
 ,IN        `dt` datetime
)
BEGIN
  SELECT
    `sm`.`id`
   ,`after`.`user` AS `updater`
   ,`after`.`created` AS `updated`
  FROM `ezp_swimlane` AS `sl`
  JOIN `ezp_swim` AS `sm`
    ON `sm`.`swimpool`=`sl`.`swimpool`
   AND `sm`.`swimlane`=`sl`.`code`
  JOIN (
    SELECT
      `swim_id`
     ,`swimpool`
     ,MAX(`created`) AS `created`
    FROM `ezp_swimlog`
    WHERE `created`<=ezpCTZOut(dt)
    GROUP BY `swim_id`
  ) AS `old`
    ON `old`.`swim_id`=`sm`.`id`
  JOIN  `ezp_swimlog` AS `before`
    ON `before`.`swim_id`=`old`.`swim_id`
   AND `before`.`created`=`old`.`created`
  JOIN (
    SELECT
      `swim_id`
     ,`swimpool`
     ,MIN(`created`) AS `created`
    FROM `ezp_swimlog`
    WHERE `created`>ezpCTZOut(dt)
    GROUP BY `swim_id`
  ) AS `new`
    ON `new`.`swim_id`=`sm`.`id`
  JOIN  `ezp_swimlog` AS `after`
    ON `after`.`swim_id`=`new`.`swim_id`
   AND `after`.`created`=`new`.`created`
  WHERE `before`.`swimpool`=swimpoolCode
    AND `after`.`swimpool`!=`before`.`swimpool`
  ;
END$$


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
      CONCAT(`swims`.`status`,'::',`swims`.`quantity`)
      SEPARATOR ';;'
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
   ,`log`.`user` AS `updater`
   ,IFNULL(`recent`.`edits`,0) AS `edits_recent`
  FROM `ezp_swimlane` AS `sl`
  JOIN `ezp_swim` AS `sm`
    ON `sm`.`swimpool`=`sl`.`swimpool`
   AND `sm`.`swimlane`=`sl`.`code`
   AND `sm`.`status`=statusCode
  JOIN (
    SELECT
      `swim_id`
     ,MAX(`created`) AS `created`
    FROM `ezp_swimlog`
    GROUP BY `swim_id`
  ) AS `last`
    ON `last`.`swim_id`=`sm`.`id`
  JOIN `ezp_swimlog` AS `log`
    ON `log`.`swim_id`=`sm`.`id`
   AND `log`.`created`=`last`.`created`
  LEFT JOIN (
    SELECT
      `swim_id`
     ,COUNT(*) AS `edits`
    FROM `ezp_swimlog`
    WHERE DATE(`created`)>=DATE_SUB(CURDATE(),INTERVAL 7 DAY)
    GROUP BY `swim_id`
  ) AS `recent`
    ON `recent`.`swim_id`=`sm`.`id`
  WHERE `sl`.`swimpool`=swimpoolCode
    AND `sl`.`code`=swimlaneCode
  ORDER BY `sm`.`updated` DESC
  ;
END$$


DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpSwimlanesUpdates`$$
CREATE PROCEDURE `ezpSwimlanesUpdates`(
  IN        `swimpoolCode` CHAR(4) CHARSET ascii
 ,IN        `dt` datetime
 ,IN        `lmt` int(11) unsigned
)
BEGIN
  SELECT
    `sm`.*
   ,`log`.`user` AS `updater`
  FROM `ezp_swimlane` AS `sl`
  JOIN `ezp_swim` AS `sm`
    ON `sm`.`swimpool`=`sl`.`swimpool`
   AND `sm`.`swimlane`=`sl`.`code`
  JOIN (
    SELECT
      `swim_id`
     ,MAX(`created`) AS `created`
    FROM `ezp_swimlog`
    GROUP BY `swim_id`
  ) AS `last`
    ON `last`.`swim_id`=`sm`.`id`
  JOIN `ezp_swimlog` AS `log`
    ON `log`.`swim_id`=`sm`.`id`
   AND `log`.`created`=`last`.`created`
  WHERE `sl`.`swimpool`=swimpoolCode
    AND `last`.`created`>ezpCTZOut(dt)
  LIMIT lmt
  ;
END$$


DELIMITER ;

