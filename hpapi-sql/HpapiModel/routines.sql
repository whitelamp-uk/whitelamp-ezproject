
SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';


DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpSetPasswordHash`$$
CREATE PROCEDURE `ezpSetPasswordHash`(
    IN `userId` INT(11) UNSIGNED
   ,IN `passwordHash` VARCHAR(255) CHARSET ascii
   ,IN `expiresTs` INT(11) UNSIGNED
   ,IN `verifiedState` INT(1) UNSIGNED
)
BEGIN
  UPDATE `hpapi_user`
  SET
    `password_hash`=passwordHash
   ,`password_expires`=FROM_UNIXTIME(expiresTs)
   ,`verified`=IFNULL(verifiedState,`verified`)
  WHERE `id`=userId
  ;
END$$

DELIMITER $$
DROP PROCEDURE IF EXISTS `ezpSwimlanesUsers`$$
CREATE PROCEDURE `ezpSwimlanesUsers`(
    IN `uid` INT(11) UNSIGNED
)
BEGIN
  SELECT
    `u`.`id` AS `userId`
   ,`u`.`name`
   ,GROUP_CONCAT(`m`.`usergroup` SEPARATOR ':') AS `groups`
  FROM `hpapi_user` AS `u`
  JOIN `hpapi_membership` AS `auth`
    ON `auth`.`user_id`=`u`.`id`
   AND `auth`.`usergroup`='swimlanes'
  LEFT JOIN `hpapi_membership` AS `m`
         ON `m`.`user_id`=`u`.`id`
        AND `m`.`usergroup`!='swimlanes'
  WHERE `u`.`active`=1
    AND ( uid IS NULL OR uid=0 OR `u`.`id`=uid )
  GROUP BY `u`.`id`
  ;
END$$


DELIMITER ;

