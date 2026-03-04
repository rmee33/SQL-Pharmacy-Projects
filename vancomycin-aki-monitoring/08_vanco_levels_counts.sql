/*
Project: Vancomycin AKI Monitoring (Portfolio / De-identified)
Purpose: Count vancomycin levels (random/peak/trough) drawn before and after the first dose.
Inputs (logical): analytics.vanco_labs_before, analytics.vanco_labs_after_single_course, analytics.vanco_labs_after_multi_course, analytics.vanco_first_last_dates
Outputs: analytics.vanco_levels_counts

Privacy & portability:
- Schema/table names are anonymized; logic preserved.
- No PHI included in this portfolio version.
- Component codes are retained as examples; map to your local dictionary as needed.

Parameters / assumptions:
  - @level_component_codes (random/peak/trough examples in script)
*/

/*
Legacy header (kept for provenance; identifiers generalized):
/************************************************************************************************************************************************************************************************************
* Description: The number of levels (Vancomycin Rn, Vancomycin Pk, Vancomycin Tr) taken * * before and after the first dose of vancomycin.
* Author: Rebecca Mead
* SAM Date: 08/18/2023
************************************************************************************************************************************************************************************************************
** Change History
************************************************************************************************************************************************************************************************************
**PR    Date            Author          Description
**1	
************************************************************************************************************************************************************************************************************/
*/

WITH PreVancLevels AS
(
SELECT 
	rb.encounter_key
	,COUNT(*) AS PreLevelsTaken
FROM analytics.vanco_labs_before rb
INNER JOIN analytics.vanco_first_last_dates fl
	ON rb.encounter_key = fl.encounter_key
	WHERE component_code IN
		( 
		'5103693' -- Vancomycin Rn
		,'5103701' --Vancomycin Pk
		,'5103709' --Vancomycin Tr
		)
	AND result_ts BETWEEN fl.first_admin_ts AND fl.last_admin_ts
GROUP BY rb.encounter_key
),

PostVancLevels AS
(
SELECT 
	ra.encounter_key
	,COUNT(*) AS PostLevelsTaken
FROM pharmacy.VancomycinResultsAfter ra
INNER JOIN analytics.vanco_first_last_dates fl
	ON ra.encounter_key = fl.encounter_key
	WHERE component_code IN
		( 
		'5103693' -- Vancomycin Rn
		,'5103701' --Vancomycin Pk
		,'5103709' --Vancomycin Tr
		)
GROUP BY ra.encounter_key
)

SELECT 
	iv.encounter_key
	,pr.PreLevelsTaken
	,po.PostLevelsTaken
FROM pharmacy.vanco_iv_administrations iv
LEFT JOIN PreVancLevels pr
	ON pr.encounter_key = iv.encounter_key
LEFT JOIN PostVancLevels po
	ON po.encounter_key = iv.encounter_key

GROUP BY 
	iv.encounter_key
	,pr.PreLevelsTaken
	,po.PostLevelsTaken
