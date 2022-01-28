
DELIMITER $$
DROP FUNCTION IF EXISTS `ezpConfig`$$
CREATE FUNCTION `ezpConfig` (
  param varchar(64) character set ascii
) RETURNS varchar(255) character set utf8
BEGIN
  IF param='timeSheetLimitToAfter' THEN BEGIN
    RETURN '2020-01-05'
    ;
    END
    ;
  END IF
  ;
  RETURN '';
END$$



