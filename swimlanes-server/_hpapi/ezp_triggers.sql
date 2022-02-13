
DELIMITER $$
DROP TRIGGER IF EXISTS `swimAfterInsert`$$
CREATE TRIGGER `swimAfterInsert`
AFTER INSERT ON `ezp_swim` FOR EACH ROW
BEGIN
  DECLARE usr varchar(255);
  SELECT USER() INTO usr;
  INSERT INTO `ezp_swimlog` (
    `user`,`swim_id`,`parent_swim_id`,
    `swimpool`,`swimlane`,`status`,
    `project`,`name`,
    `notes`,`specification`,`dev_log`
  )
  VALUES (
    usr,NEW.`id`,NEW.`parent_swim_id`,
    LOWER(NEW.`swimpool`),LOWER(NEW.`swimlane`),LOWER(NEW.`status`),
    LOWER(NEW.`project`),NEW.`name`,
    NEW.`notes`,NEW.`specification`,NEW.`dev_log`
  );
END$$

DELIMITER $$
DROP TRIGGER IF EXISTS `swimAfterUpdate`$$
CREATE TRIGGER `swimAfterUpdate`
AFTER UPDATE ON `ezp_swim` FOR EACH ROW
BEGIN
  DECLARE usr varchar(255);
  SELECT USER() INTO usr;
  INSERT INTO `ezp_swimlog` (
    `user`,`swim_id`,`parent_swim_id`,
    `swimpool`,`swimlane`,`status`,
    `project`,`name`,
    `notes`,`specification`,`dev_log`
  )
  VALUES (
    usr,NEW.`id`,NEW.`parent_swim_id`,
    LOWER(NEW.`swimpool`),LOWER(NEW.`swimlane`),LOWER(NEW.`status`),
    LOWER(NEW.`project`),NEW.`name`,
    NEW.`notes`,NEW.`specification`,NEW.`dev_log`
  );
END$$


DELIMITER $$
DROP TRIGGER IF EXISTS `swimBeforeDelete`$$
CREATE TRIGGER `swimBeforeDelete`
BEFORE DELETE ON `ezp_swim` FOR EACH ROW
BEGIN
  DECLARE usr varchar(255);
  SELECT USER() INTO usr;
  INSERT INTO `ezp_swimlog` (
    `user`,`swim_id`,
    `parent_swim_id`,`swimpool`,
    `swimlane`,`status`,
    `project`,`name`,
    `notes`,`specification`,`dev_log`
  )
  VALUES (
    usr,OLD.`id`,OLD.`parent_swim_id`,
    OLD.`swimpool`,OLD.`swimlane`,OLD.`status`,
    LOWER(OLD.`project`),OLD.`name`,
    OLD.`notes`,OLD.`specification`,OLD.`dev_log`
  );
END$$

