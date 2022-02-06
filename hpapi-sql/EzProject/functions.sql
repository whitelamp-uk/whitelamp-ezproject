

DELIMITER $$
DROP FUNCTION IF EXISTS `ezpCTZIn`$$
CREATE FUNCTION `ezpCTZIn` (
  t timestamp
) RETURNS timestamp DETERMINISTIC
BEGIN
  IF (@hpapiTimezone IS NULL) THEN BEGIN
    SET @hpapiTimezone = 'Europe/London'
    ;
    END
    ;
  END IF
  ;
  RETURN CONVERT_TZ(t,@hpapiTimezone,'UTC');
END$$


DELIMITER $$
DROP FUNCTION IF EXISTS `ezpCTZOut`$$
CREATE FUNCTION `ezpCTZOut` (
  t timestamp
) RETURNS timestamp DETERMINISTIC
BEGIN
  IF (@hpapiTimezone IS NULL) THEN BEGIN
    SET @hpapiTimezone = 'Europe/London'
    ;
    END
    ;
  END IF
  ;
  RETURN CONVERT_TZ(t,'UTC',@hpapiTimezone);
END$$


DELIMITER ;

