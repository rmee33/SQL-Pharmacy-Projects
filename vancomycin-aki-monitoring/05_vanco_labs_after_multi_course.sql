/*
Project: Vancomycin AKI Monitoring (Portfolio / De-identified)
Purpose: Extract relevant lab results after the first dose for course 1 and before the first dose of course 2 (multi-course encounters).
Inputs (logical): analytics.vanco_first_last_dates, ehr.lab_result
Outputs: analytics.vanco_labs_after_multi_course

Privacy & portability:
- Schema/table names are anonymized; logic preserved.
- No PHI included in this portfolio version.
- Component codes are retained as examples; map to your local dictionary as needed.

Parameters / assumptions:
  - @gap_days (must match course logic)
  - @lab_component_codes
*/

/*
Legacy header (kept for provenance; identifiers generalized):
/************************************************************************************************************************************************************************************************************
* Description: For patients with more than one course of therapy, the lab results of interest after * the first dose of vancomycin for the first course of therapy, and before the first dose of 
* vancomycin for the second course of therapy.
* SAM Date: 08/18/2023
************************************************************************************************************************************************************************************************************
** Change History
************************************************************************************************************************************************************************************************************
**PR    Date            Author          Description
**1	
************************************************************************************************************************************************************************************************************/
*/

--Finding EncounterIDs with more than one course of therapy
WITH multi AS
	(
	SELECT 
		encounter_key
	FROM analytics.vanco_first_last_dates
	GROUP BY 
		encounter_key
	HAVING COUNT(encounter_key) > 1
	),
--pulling the first admin date for the first course of therapy and 
--the first admin date for the second course of therapy
multidts AS
	(
	SELECT 
			mi.encounter_key
			,iv1.first_admin_ts AS FirstAdminDTS1
			,iv2.first_admin_ts AS FirstAdminDTS2
	FROM multi mi
	LEFT JOIN analytics.vanco_first_last_dates iv1
		ON mi.encounter_key = iv1.encounter_key
		AND iv1.TherapyCourseNUM = 1
	LEFT JOIN analytics.vanco_first_last_dates iv2
		ON mi.encounter_key = iv2.encounter_key
		AND iv2.TherapyCourseNUM = 2 
	)

--getting lab results that occured after the first administration of vanc
--and before the second course of therapy
SELECT 
	lr.encounter_key
	,component_code
	,component_name
	,CollectedDTS
	,ce.EventEndDTS
	,result_ts
	,result_value 
 FROM ehr.LabResult lr
INNER JOIN ehr.Event ce
  ON ce.EventID = lr.LabResultID
  AND ce.ViewLevelFLG = 1
INNER JOIN multidts mu
	ON lr.encounter_key = mu.encounter_key
	WHERE 
		lr.component_code IN
		( 
		'2700655' --Creatinine
		,'1112015715' --est. CrCl
		,'5103693' -- Vancomycin Rn
		,'5103701' --Vancomycin  Pk
		,'5103709' --Vancomycin Tr
		)
		AND ce.EventEndDTS BETWEEN mu.FirstAdminDTS1 AND mu.FirstAdminDTS2

    GROUP BY 
  	lr.encounter_key
  	,component_code
  	,component_name
  	,CollectedDTS
  	,ce.EventEndDTS
  	,result_ts
  	,result_value
