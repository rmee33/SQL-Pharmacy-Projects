/*
Project: Vancomycin AKI Monitoring (Portfolio / De-identified)
Purpose: Extract relevant lab results after the first vancomycin dose for encounters with a single therapy course.
Inputs (logical): analytics.vanco_first_last_dates, ehr.lab_result
Outputs: analytics.vanco_labs_after_single_course

Privacy & portability:
- Schema/table names are anonymized; logic preserved.
- No PHI included in this portfolio version.
- Component codes are retained as examples; map to your local dictionary as needed.

Parameters / assumptions:
  - @post_window_end_ts (e.g., discharge_ts)
  - @lab_component_codes
*/

/*
Legacy header (kept for provenance; identifiers generalized):
/************************************************************************************************************************************************************************************************************
* Description: Lab results of interest after the first dose of vancomycin for the first course of 
* therapy, for patients that have had only one course of therapy.
* SAM Date: 08/18/2023
************************************************************************************************************************************************************************************************************
** Change History
************************************************************************************************************************************************************************************************************
**PR    Date            Author          Description
**1	
************************************************************************************************************************************************************************************************************/
*/

--Finding EncounterIDs with a single course of therapy
WITH single AS
	(
	SELECT 
		encounter_key
	FROM analytics.vanco_first_last_dates
	GROUP BY 
		encounter_key
	HAVING COUNT(encounter_key) = 1
	),

FirstVanc AS
(
	SELECT 
		si.encounter_key
		,iv.first_admin_ts 
	FROM single si
	LEFT JOIN analytics.vanco_first_last_dates iv
		ON si.encounter_key = iv.encounter_key
)

--Everything > first vanco date
SELECT 
	lr.encounter_key
	,lr.component_code
	,lr.component_name
	,lr.CollectedDTS
	,ce.EventEndDTS
	,lr.result_ts
	,lr.result_value
 FROM ehr.LabResult lr
INNER JOIN ehr.Event ce
  ON ce.EventID = lr.LabResultID
  AND ce.ViewLevelFLG = 1
INNER JOIN FirstVanc fv
	ON lr.encounter_key = fv.encounter_key
	WHERE 
		lr.component_code IN
		( 
		'2700655' --Creatinine
		,'1112015715' --est. CrCl
		,'5103693' -- Vancomycin Rn
		,'5103701' --Vancomycin  Pk
		,'5103709' --Vancomycin Tr
		)
		AND ce.EventEndDTS > fv.first_admin_ts 
    GROUP BY 
    	lr.encounter_key
    	,component_code
    	,component_name
    	,CollectedDTS
    	,ce.EventEndDTS
    	,result_ts
    	,result_value
