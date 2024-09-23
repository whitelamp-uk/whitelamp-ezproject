
DELIMITER $$
DROP FUNCTION IF EXISTS `ezpSwimlanesPermit`$$
CREATE FUNCTION `ezpSwimlanesPermit` (
  statusFrom char (16) CHARACTER SET 'ascii'
 ,statusTo char (16) CHARACTER SET 'ascii'
 ,permitUser varchar(254) CHARACTER SET 'ascii'
) RETURNS tinyint(1) unsigned DETERMINISTIC
BEGIN
  DECLARE found tinyint(1) unsigned
  ;
  IF statusTo=statusFrom THEN
    RETURN 1;
  END IF
  ;
  SELECT COUNT(*) INTO found
  FROM `ezp_swimpermit` AS `p`
  JOIN `hpapi`.`hpapi_membership` AS `hm`
    ON `hm`.`usergroup`=`p`.`usergroup`
  JOIN `hpapi`.`hpapi_user` AS `hu`
    ON `hu`.`id`=`hm`.`user_id`
  JOIN `ezp_user` AS `u`
    ON `u`.`email`=`hu`.`email`
   AND `u`.`code`=permitUser
  WHERE `p`.`status_from`=statusFrom
    AND `p`.`status_to`=statusTo
  ;
  RETURN found
  ;
END$$


DELIMITER $$
DROP FUNCTION IF EXISTS `ezpSwimlanesIsQC`$$
CREATE FUNCTION `ezpSwimlanesIsQC` (
  statusCode char (16) CHARACTER SET 'ascii'
) RETURNS tinyint(1) unsigned DETERMINISTIC
BEGIN
  DECLARE isqc tinyint(1) unsigned
  ;
  SELECT `is_qc` INTO isqc
  FROM `ezp_swimstatus`
  WHERE `code`=statusCode
  ;
  IF isqc>0 THEN
    RETURN 1
    ;
  END IF
  ;
  RETURN 0
  ;
END$$


DELIMITER $$
DROP FUNCTION IF EXISTS `ezpSwimlanesUserCode`$$
CREATE FUNCTION `ezpSwimlanesUserCode` (
  userDeclared varchar (254) CHARACTER SET 'ascii'
) RETURNS char(16) CHARACTER SET 'ascii' DETERMINISTIC
BEGIN
  DECLARE c char(16) CHARACTER SET 'ascii'
  ;
  -- check for API shared service eg swimlanes@localhost
  SELECT `code` INTO c
  FROM `ezp_user`
  WHERE `sql_user`=USER()
    AND `email` IS NULL
  ;
  IF c IS NOT NULL THEN
    -- accept the declared API user as legitimate
    -- provided it exists
    SET  c = null
    ;
    SELECT `code` INTO c
    FROM `ezp_user`
    WHERE `code`=userDeclared
      AND `email` IS NOT NULL
    ;
    IF c IS NOT NULL THEN
      RETURN c
      ;
    END IF
    ;
  ELSE
    -- return the code for the current SQL user
    -- provided it exists
    SET  c = null
    ;
    SELECT `code` INTO c
    FROM `ezp_user`
    WHERE `sql_user`=USER()
      AND `email` IS NOT NULL
    ;
    IF c IS NOT NULL THEN
      RETURN c
      ;
    END IF
    ;
  END IF
  ;
  SIGNAL SQLSTATE 'ERROR' SET MESSAGE_TEXT = 'ezpSwimlanesUserCode() could not identify user'
  ;
END$$

