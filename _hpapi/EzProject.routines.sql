-- Adminer 4.7.5 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';


DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpApp`$$
CREATE PROCEDURE `ezpApp`(
  IN        `app` VARCHAR(64) CHARSET ascii
)
BEGIN
  SELECT
    SUM(`ezp_estimate`.`hours`) AS `Total_Estimated`
   ,ROUND(SUM(`ezp_estimate`.`hours`*(100-`ezp_component`.`progress_pct`)/100),1) AS `Total_Remaining`
  FROM `ezp_component`
  JOIN `ezp_difficulty`
    ON `ezp_difficulty`.`difficulty`=`ezp_component`.`difficulty`
  JOIN `ezp_estimate`
    ON `ezp_estimate`.`difficulty`=`ezp_difficulty`.`difficulty`
   AND `ezp_estimate`.`devtype`=`ezp_component`.`devtype`
  WHERE `ezp_component`.`package` LIKE CONCAT(app,'-%')
  ;
  SELECT
    `ezp_component`.`vendor`
   ,`ezp_component`.`package`
   ,`ezp_component`.`handle`
   ,`ezp_component`.`devtype`
   ,`ezp_difficulty`.`difficulty` AS `Difficulty_Level`
   ,`ezp_estimate`.`hours` AS `Estimated_Hours`
   ,ROUND(`ezp_estimate`.`hours`*((100-`ezp_component`.`progress_pct`)/100),1) AS `Hours_Remaining`
  FROM `ezp_component`
  JOIN `ezp_difficulty`
    ON `ezp_difficulty`.`difficulty`=`ezp_component`.`difficulty`
  JOIN `ezp_estimate`
    ON `ezp_estimate`.`difficulty`=`ezp_difficulty`.`difficulty`
   AND `ezp_estimate`.`devtype`=`ezp_component`.`devtype`
  WHERE `ezp_component`.`package` LIKE CONCAT(app,'-%')
  ORDER BY `ezp_component`.`devtype`,`ezp_component`.`package`,`ezp_component`.`handle`
  ;
END$$

DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpJobs`$$
CREATE PROCEDURE `ezpJobs`(
  IN        `developer` VARCHAR(64) CHARSET ascii
)
BEGIN
  SELECT
    `ezp_component`.`vendor`
   ,`ezp_component`.`package`
   ,`ezp_component`.`handle`
   ,`ezp_component`.`devtype`
   ,`ezp_difficulty`.`difficulty` AS `Difficulty_Level`
   ,`ezp_estimate`.`hours` AS `Estimated_Hours`
   ,ROUND(`ezp_estimate`.`hours`*((100-`ezp_component`.`progress_pct`)/100),1) AS `Hours_Remaining`
   ,`ezp_component`.`required_by`
   ,`ezp_component`.`notes`
  FROM `ezp_component`
  JOIN `ezp_difficulty`
    ON `ezp_difficulty`.`difficulty`=`ezp_component`.`difficulty`
  JOIN `ezp_estimate`
    ON `ezp_estimate`.`difficulty`=`ezp_difficulty`.`difficulty`
   AND `ezp_estimate`.`devtype`=`ezp_component`.`devtype`
  WHERE `ezp_component`.`developer`=developer
    AND `ezp_component`.`progress_pct`<100
  ORDER BY `ezp_component`.`required_by` IS NULL,`ezp_component`.`required_by`
  ;
END$$

DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpPackage`$$
CREATE PROCEDURE `ezpPackage`(
  IN        `pkg` VARCHAR(64) CHARSET ascii
)
BEGIN
  SELECT
    SUM(`ezp_estimate`.`hours`) AS `Total_Estimated`
   ,ROUND(SUM(`ezp_estimate`.`hours`*(100-`ezp_component`.`progress_pct`)/100),1) AS `Total_Remaining`
  FROM `ezp_component`
  JOIN `ezp_difficulty`
    ON `ezp_difficulty`.`difficulty`=`ezp_component`.`difficulty`
  JOIN `ezp_estimate`
    ON `ezp_estimate`.`difficulty`=`ezp_difficulty`.`difficulty`
   AND `ezp_estimate`.`devtype`=`ezp_component`.`devtype`
  WHERE `ezp_component`.`package`=pkg
  ;
  SELECT
    `ezp_component`.`vendor`
   ,`ezp_component`.`package`
   ,`ezp_component`.`handle`
   ,`ezp_component`.`devtype`
   ,`ezp_difficulty`.`difficulty` AS `Difficulty_Level`
   ,`ezp_estimate`.`hours` AS `Estimated_Hours`
   ,ROUND(`ezp_estimate`.`hours`*((100-`ezp_component`.`progress_pct`)/100),1) AS `Hours_Remaining`
   ,`ezp_component`.`notes`
  FROM `ezp_component`
  JOIN `ezp_difficulty`
    ON `ezp_difficulty`.`difficulty`=`ezp_component`.`difficulty`
  JOIN `ezp_estimate`
    ON `ezp_estimate`.`difficulty`=`ezp_difficulty`.`difficulty`
   AND `ezp_estimate`.`devtype`=`ezp_component`.`devtype`
  WHERE `ezp_component`.`package`=pkg
  ORDER BY `ezp_component`.`devtype`,`ezp_component`.`handle`
  ;
END$$

DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpSummary`$$
CREATE PROCEDURE `ezpSummary`(
)
BEGIN
  SELECT
    SUM(`ezp_estimate`.`hours`) AS `Total_Estimated`
   ,ROUND(SUM(`ezp_estimate`.`hours`*(100-`ezp_component`.`progress_pct`)/100),1) AS `Total_Remaining`
  FROM `ezp_component`
  JOIN `ezp_difficulty`
    ON `ezp_difficulty`.`difficulty`=`ezp_component`.`difficulty`
  JOIN `ezp_estimate`
    ON `ezp_estimate`.`difficulty`=`ezp_difficulty`.`difficulty`
   AND `ezp_estimate`.`devtype`=`ezp_component`.`devtype`
  WHERE 1
  ;
  SELECT
    `ezp_component`.`vendor`
   ,`ezp_component`.`package`
   ,SUM(`ezp_estimate`.`hours`) AS `Estimated_Hours`
   ,ROUND(SUM(`ezp_estimate`.`hours`*((100-`ezp_component`.`progress_pct`)/100)),1) AS `Hours_Remaining`
  FROM `ezp_component`
  JOIN `ezp_difficulty`
    ON `ezp_difficulty`.`difficulty`=`ezp_component`.`difficulty`
  JOIN `ezp_estimate`
    ON `ezp_estimate`.`difficulty`=`ezp_difficulty`.`difficulty`
   AND `ezp_estimate`.`devtype`=`ezp_component`.`devtype`
  WHERE 1
  GROUP BY `ezp_component`.`package`
  ORDER BY `ezp_component`.`package`
  ;
END$$

DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpTimesheet`$$
CREATE PROCEDURE `ezpTimesheet`(
    IN `monthOrEmptyForAll` char(7) charset ascii
   ,IN `weekEndedSundayOrEmptyForAll` date
   ,IN `developerOrEmptyForAll` varchar(64) charset ascii
   ,IN `projectOrEmptyForAll` varchar(64) charset ascii
)
BEGIN
  SELECT
    `id`
   ,`day`
   ,DAYNAME(`day`) AS `dow`
   ,`hours`
   ,`developer`
   ,`project`
   ,`comment`
   ,`vendor`
   ,`package`
   ,`handle`
  FROM `ezp_timesheet`
  WHERE 1
    AND (
         monthOrEmptyForAll IS NULL
      OR monthOrEmptyForAll=''
      OR monthOrEmptyForAll='0000-00'
      OR `day` LIKE CONCAT(monthOrEmptyForAll,'-__')
    )
    AND (
         weekEndedSundayOrEmptyForAll IS NULL
      OR weekEndedSundayOrEmptyForAll=''
      OR weekEndedSundayOrEmptyForAll='0000-00-00'
      OR (
           DAYOFWEEK(weekEndedSundayOrEmptyForAll)=1
       AND `day`>DATE_SUB(weekEndedSundayOrEmptyForAll,INTERVAL 1 WEEK)
       AND `day`<=weekEndedSundayOrEmptyForAll
      )
    )
    AND (
         projectOrEmptyForAll IS NULL
      OR projectOrEmptyForAll=''
      OR `project`=projectOrEmptyForAll
    )
    AND (
        developerOrEmptyForAll IS NULL
     OR developerOrEmptyForAll=''
     OR `developer`=developerOrEmptyForAll
    )
  ORDER BY `day`,`project`,`developer`,`id`
  ;
  SELECT
    SUM(`hours`) AS `total_hours`
   ,`developer`
   ,`project`
  FROM `ezp_timesheet`
  WHERE 1
    AND (
         monthOrEmptyForAll IS NULL
      OR monthOrEmptyForAll=''
      OR monthOrEmptyForAll='0000-00'
      OR `day` LIKE CONCAT(monthOrEmptyForAll,'-__')
    )
    AND (
         weekEndedSundayOrEmptyForAll IS NULL
      OR weekEndedSundayOrEmptyForAll=''
      OR weekEndedSundayOrEmptyForAll='0000-00-00'
      OR (
           DAYOFWEEK(weekEndedSundayOrEmptyForAll)=1
       AND `day`>DATE_SUB(weekEndedSundayOrEmptyForAll,INTERVAL 1 WEEK)
       AND `day`<=weekEndedSundayOrEmptyForAll
      )
    )
    AND (
         projectOrEmptyForAll IS NULL
      OR projectOrEmptyForAll=''
      OR `project`=projectOrEmptyForAll
    )
    AND (
        developerOrEmptyForAll IS NULL
     OR developerOrEmptyForAll=''
     OR `developer`=developerOrEmptyForAll
    )
  GROUP BY `project`,`developer`
  ORDER BY `project`,`developer`
  ;
END$$

DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpUnassigned`$$
CREATE PROCEDURE `ezpUnassigned`(
  IN        `app` VARCHAR(64) CHARSET ascii
)
BEGIN
  SELECT
    `ezp_component`.`vendor`
   ,`ezp_component`.`package`
   ,`ezp_component`.`handle`
   ,`ezp_component`.`devtype`
   ,`ezp_difficulty`.`difficulty` AS `Difficulty_Level`
   ,`ezp_estimate`.`hours` AS `Estimated_Hours`
   ,ROUND(`ezp_estimate`.`hours`*((100-`ezp_component`.`progress_pct`)/100),1) AS `Hours_Remaining`
   ,`ezp_component`.`required_by`
   ,`ezp_component`.`notes`
  FROM `ezp_component`
  JOIN `ezp_difficulty`
    ON `ezp_difficulty`.`difficulty`=`ezp_component`.`difficulty`
  JOIN `ezp_estimate`
    ON `ezp_estimate`.`difficulty`=`ezp_difficulty`.`difficulty`
   AND `ezp_estimate`.`devtype`=`ezp_component`.`devtype`
  WHERE `ezp_component`.`package` LIKE CONCAT(app,'-%')
    AND `ezp_component`.`developer` IS NULL
  ORDER BY `ezp_component`.`devtype`,`ezp_component`.`handle`
  ;
END$$

DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpUnscheduled`$$
CREATE PROCEDURE `ezpUnscheduled`(
  IN        `app` VARCHAR(64) CHARSET ascii
)
BEGIN
  SELECT
    `ezp_component`.`vendor`
   ,`ezp_component`.`package`
   ,`ezp_component`.`handle`
   ,`ezp_component`.`devtype`
   ,`ezp_difficulty`.`difficulty` AS `Difficulty_Level`
   ,`ezp_estimate`.`hours` AS `Estimated_Hours`
   ,ROUND(`ezp_estimate`.`hours`*((100-`ezp_component`.`progress_pct`)/100),1) AS `Hours_Remaining`
   ,`ezp_component`.`developer`
   ,`ezp_component`.`notes`
  FROM `ezp_component`
  JOIN `ezp_difficulty`
    ON `ezp_difficulty`.`difficulty`=`ezp_component`.`difficulty`
  JOIN `ezp_estimate`
    ON `ezp_estimate`.`difficulty`=`ezp_difficulty`.`difficulty`
   AND `ezp_estimate`.`devtype`=`ezp_component`.`devtype`
  WHERE `ezp_component`.`package` LIKE CONCAT(app,'-%')
    AND `ezp_component`.`required_by` IS NULL
  ORDER BY `ezp_component`.`devtype`,`ezp_component`.`handle`
  ;
END$$

DELIMITER ;

-- 2020-01-02 17:09:09
