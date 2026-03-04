/*
Project: Vancomycin AKI Monitoring (Portfolio / De-identified)
Purpose: Identify the first serum creatinine result within ±12 hours of the first vancomycin dose.
Inputs (logical): ehr.lab_result, analytics.vanco_first_last_dates
Outputs: analytics.vanco_first_scr_24h

Privacy & portability:
- Schema/table names are anonymized; logic preserved.
- No PHI included in this portfolio version.
- Component codes are retained as examples; map to your local dictionary as needed.

Parameters / assumptions:
  - @scr_component_code (example in script)
  - @window_hours = 12
*/

/*
Legacy header (kept for provenance; identifiers generalized):
/************************************************************************************************************************************************************************************************************
* Description: The first SCr lab result to take place between 12 hours before or 12 hours after the * first dose of vancomycin. 
* Author: Rebecca Mead
* SAM Date: 08/18/2023
************************************************************************************************************************************************************************************************************
** Change History
************************************************************************************************************************************************************************************************************
**PR    Date            Author          Description
**1	
************************************************************************************************************************************************************************************************************/
*/

SELECT
	encounter_key
	,component_code
	,component_name
  ,result_ts AS FirstScR24HrVancoDTS
	,result_value AS FirstScR24HrVancoNBR
FROM
	(SELECT t.*
		,ROW_Number() OVER(PARTITION BY fv.encounter_key ORDER BY result_ts ASC) AS RowNumber
	FROM ehr.LabResult t
	INNER JOIN analytics.vanco_first_last_dates fv
		ON t.encounter_key = fv.encounter_key
	WHERE 
		component_code = '2700655' --Creatinine
		AND t.result_ts BETWEEN DATEADD(MINUTE, -720, fv.first_admin_ts) AND DATEADD(MINUTE, 720, fv.last_admin_ts)

	) AS tmp
WHERE RowNumber = 1
