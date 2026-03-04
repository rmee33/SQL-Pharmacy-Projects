/*
Project: Vancomycin AKI Monitoring (Portfolio / De-identified)
Purpose: Compute median pre-vancomycin baseline labs (e.g., SCr) per encounter.
Inputs (logical): analytics.vanco_labs_before
Outputs: analytics.vanco_pre_medians

Privacy & portability:
- Schema/table names are anonymized; logic preserved.
- No PHI included in this portfolio version.
- Component codes are retained as examples; map to your local dictionary as needed.

Parameters / assumptions:
  - @baseline_window (defined in labs_before extraction)
*/

/*
Legacy header (kept for provenance; identifiers generalized):
/************************************************************************************************************************************************************************************************************
* Description: Median lab values prior to the first dose of vancomycin.
* SAM Date: 08/18/2023
************************************************************************************************************************************************************************************************************
** Change History
************************************************************************************************************************************************************************************************************
**PR    Date            Author          Description
**1	
************************************************************************************************************************************************************************************************************/
*/

WITH scr AS
(
 SELECT
	encounter_key
	,result_ts
	,result_value
	,PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY result_value) 
	OVER(PARTITION BY encounter_key) AS PreVancMedianSCr
FROM (
	SELECT
	encounter_key
	,component_code
	,result_ts
	,result_value
FROM analytics.vanco_labs_before
	GROUP BY
	 encounter_key
	,component_code
	 ,result_ts
	 ,result_value
  HAVING component_code = '2700655' --Creatinine
	)a),
  
crcl AS
(
SELECT
	encounter_key
	,result_ts
	,result_value
	,PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY result_value) 
	OVER(PARTITION BY encounter_key) AS PreVancMedianCrCl
FROM (
	SELECT
	encounter_key
	,component_code
	,result_ts
	,result_value
FROM analytics.vanco_labs_before
	GROUP BY
	 encounter_key
	,component_code
	,result_ts
	,result_value
  HAVING component_code = '1112015715' --est. CrCl
	)b)
  
  SELECT
	  scr.encounter_key
	  ,scr.PreVancMedianSCr
	  ,crcl.PreVancMedianCrCl
  FROM scr
  LEFT JOIN crcl
	 ON scr.encounter_key = crcl.encounter_key
  GROUP BY
   scr.encounter_key
  ,scr.PreVancMedianSCr
  ,crcl.PreVancMedianCrCl
