
DELIMITER $$
DROP TRIGGER IF EXISTS `swimAfterInsert`$$
CREATE TRIGGER `swimAfterInsert`
AFTER INSERT ON `ezp_swim` FOR EACH ROW
BEGIN
  INSERT INTO `ezp_swimlog` (
    `last_user`,`swim_id`,`parent_swim_id`,`csip_ref`,
    `swimpool`,`swimlane`,`status`,
    `progress_by_date`,`close_by_date`,`name`
  )
  VALUES (
    NEW.`last_user`,NEW.`id`,NEW.`parent_swim_id`,NEW.`csip_ref`,
    LOWER(NEW.`swimpool`),LOWER(NEW.`swimlane`),LOWER(NEW.`status`),
    NEW.`progress_by_date`,NEW.`close_by_date`,NEW.`name`
  );
END$$

DELIMITER $$
DROP TRIGGER IF EXISTS `swimAfterUpdate`$$
CREATE TRIGGER `swimAfterUpdate`
AFTER UPDATE ON `ezp_swim` FOR EACH ROW
BEGIN
  INSERT INTO `ezp_swimlog` (
    `last_user`,`swim_id`,`parent_swim_id`,`csip_ref`,
    `swimpool`,`swimlane`,`status`,
    `progress_by_date`,`close_by_date`,`name`
  )
  VALUES (
    NEW.`last_user`,NEW.`id`,NEW.`parent_swim_id`,NEW.`csip_ref`,
    LOWER(NEW.`swimpool`),LOWER(NEW.`swimlane`),LOWER(NEW.`status`),
    NEW.`progress_by_date`,NEW.`close_by_date`,NEW.`name`
  );
END$$


DELIMITER $$
DROP TRIGGER IF EXISTS `swimBeforeInsert`$$
CREATE TRIGGER `swimBeforeInsert` BEFORE INSERT ON `ezp_swim` FOR EACH ROW
BEGIN
  SET NEW.`last_user`=ezpSwimlanesUserCode(NEW.`last_user`)
  ;
  IF ezpSwimlanesPermit('opened',NEW.`status`,NEW.`last_user`)=0 THEN
    SIGNAL SQLSTATE '45000' SET message_text = 'That change of status is denied [before insert table trigger]'
    ;
  END IF
  ;
END$$


DELIMITER $$
DROP TRIGGER IF EXISTS `swimBeforeUpdate`$$
CREATE TRIGGER `swimBeforeUpdate` BEFORE UPDATE ON `ezp_swim` FOR EACH ROW
BEGIN
  SET NEW.`last_user`=ezpSwimlanesUserCode(NEW.`last_user`)
  ;
  IF ezpSwimlanesPermit(OLD.`status`,NEW.`status`,NEW.`last_user`)=0 THEN
    SIGNAL SQLSTATE '45000' SET message_text = 'That change of status is denied [before update table trigger]'
    ;
  END IF
  ;
  IF NEW.`status`!=OLD.`status` AND NEW.`last_user`=OLD.`last_user` AND ezpSwimlanesIsQC(OLD.`status`)>0  THEN
    SIGNAL SQLSTATE '45000' SET message_text = 'The status must be changed by a different user [before update table trigger]'
    ;
  END IF
  ;
END$$


DELIMITER $$
DROP TRIGGER IF EXISTS `swimnoteAfterInsert`$$
CREATE TRIGGER `swimnoteAfterInsert`
AFTER INSERT ON `ezp_swimnote` FOR EACH ROW
BEGIN
  DECLARE usr varchar(255);
  SELECT ezpSwimlanesUserCode(NEW.`last_user`) INTO usr;
  INSERT INTO `ezp_swimnotelog` (
    `last_user`,`swimnote_id`,`swim_id`,
    `type`,`title`,`body`
  )
  VALUES (
    usr,NEW.`id`,NEW.`swim_id`,
    LOWER(NEW.`type`),NEW.`title`,NEW.`body`
  );
END$$

DELIMITER $$
DROP TRIGGER IF EXISTS `swimnoteAfterUpdate`$$
CREATE TRIGGER `swimnoteAfterUpdate`
AFTER UPDATE ON `ezp_swimnote` FOR EACH ROW
BEGIN
  DECLARE usr varchar(255);
  SELECT ezpSwimlanesUserCode(NEW.`last_user`) INTO usr;
  INSERT INTO `ezp_swimnotelog` (
    `last_user`,`swimnote_id`,`swim_id`,
    `type`,`title`,`body`
  )
  VALUES (
    usr,NEW.`id`,NEW.`swim_id`,
    LOWER(NEW.`type`),NEW.`title`,NEW.`body`
  );
END$$


DELIMITER $$
DROP TRIGGER IF EXISTS `swimnoteBeforeInsert`$$
CREATE TRIGGER `swimnoteBeforeInsert` BEFORE INSERT ON `ezp_swimnote` FOR EACH ROW
BEGIN
  SET NEW.`last_user`=ezpSwimlanesUserCode(NEW.`last_user`)
  ;
END$$


DELIMITER $$
DROP TRIGGER IF EXISTS `swimnoteBeforeUpdate`$$
CREATE TRIGGER `swimnoteBeforeUpdate` BEFORE UPDATE ON `ezp_swimnote` FOR EACH ROW
BEGIN
  SET NEW.`last_user`=ezpSwimlanesUserCode(NEW.`last_user`)
  ;
END$$


DELIMITER $$
DROP TRIGGER IF EXISTS `timesheetBeforeInsert`$$
CREATE TRIGGER `timesheetBeforeInsert` BEFORE INSERT ON `ezp_timesheet` FOR EACH ROW
BEGIN
  SET NEW.`user`=LOWER(NEW.`user`),NEW.`project`=LOWER(NEW.`project`)
  ;
END$$


DELIMITER $$
DROP TRIGGER IF EXISTS `timesheetBeforeUpdate`$$
CREATE TRIGGER `timesheetBeforeUpdate` BEFORE UPDATE ON `ezp_timesheet` FOR EACH ROW
BEGIN
  SET NEW.`user`=LOWER(NEW.`user`),NEW.`project`=LOWER(NEW.`project`)
  ;
END$$

