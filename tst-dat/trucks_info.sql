-- script_version: 1.0.0
DROP VDS IF EXISTS $site_id.base_data_current.trucks_info;

CREATE VDS $site_id.base_data_current.trucks_info
  AS 
SELECT *
  FROM $site_id.base_data_cdc.trucks_info_incr t
 WHERE id$ IN (SELECT FIRST_VALUE(id$) OVER (PARTITION BY primary_key_val$ ORDER BY source_scn$ DESC, id$ DESC)
                 FROM $site_id.base_data_cdc.trucks_info_incr);
