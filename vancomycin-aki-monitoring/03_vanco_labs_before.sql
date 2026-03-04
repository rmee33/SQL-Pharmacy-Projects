/*
Project: Vancomycin AKI Monitoring (Portfolio / De-identified)
Purpose: Extract relevant lab results prior to the first vancomycin dose (first therapy course).
Inputs (logical): pharmacy.vanco_iv_administrations, ehr.lab_result
Outputs: analytics.vanco_labs_before

Privacy & portability:
- Schema/table names are anonymized; logic preserved.
- No PHI included in this portfolio version.
- Component codes are retained as examples; map to your local dictionary as needed.

Parameters / assumptions:
  - @lookback_hours (e.g., 72)
  - @lab_component_codes (INR/SCr/etc.)
*/

/*
Legacy header (kept for provenance; identifiers generalized):
/************************************************************************************************************************************************************************************************************
* Description: Lab results of interest prior to the first dose of vancomycin for the first course of 
* therapy. 
* SAM Date: 08/18/2023
************************************************************************************************************************************************************************************************************
** Change History
************************************************************************************************************************************************************************************************************
**PR    Date            Author          Description
**1	
************************************************************************************************************************************************************************************************************/
*/

WITH FirstVanc AS
(
	SELECT 
		encounter_key
		,medication_key
		,medication_name
		,discharge_ts
    ,MIN(admin_ts) AS first_vanco_ts
	FROM pharmacy.vanco_iv_administrations
	GROUP BY 
		encounter_key
		,medication_key
		,medication_name
		,discharge_ts
)

--Everything < first vanco date
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
		AND ce.EventEndDTS < fv.first_vanco_ts
  GROUP BY
  lr.encounter_key
	,lr.component_code
	,lr.component_name
	,lr.CollectedDTS
  ,ce.EventEndDTS
	,lr.result_ts
	,lr.result_value
