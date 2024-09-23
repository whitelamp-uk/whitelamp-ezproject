
CREATE OR REPLACE VIEW `Swims` AS
  SELECT
    `p`.`name` AS `pool`
   ,`l`.`name` AS `lane`
   ,`s`.*
   ,GROUP_CONCAT(
      CONCAT(
        `n`.`created`
       ,IF(
          `n`.`updated`!=`n`.`created`
         ,CONCAT(' [',`n`.`updated`,']')
         ,''
        )
       ,'\n#'
       ,`n`.`type`
       ,': '
       ,`n`.`title`
       ,' ['
       ,`n`.`sql_user`
       ,']\n'
       ,TRIM(`n`.`body`)
      )
      ORDER BY `n`.`id` DESC
      SEPARATOR '\n\n'
    ) AS `notes`
  FROM `ezp_swim` AS `s`
  LEFT JOIN `ezp_swimnote` AS `n`
    ON `n`.`swim_id`=`s`.`id`
  JOIN `ezp_swimlane` AS `l`
    ON `l`.`swimpool`=`s`.`swimpool`
   AND `l`.`code`=`s`.`swimlane`
  JOIN `ezp_swimpool` AS `p`
    ON `p`.`code`=`l`.`swimpool`
  GROUP BY `s`.`id`
;

