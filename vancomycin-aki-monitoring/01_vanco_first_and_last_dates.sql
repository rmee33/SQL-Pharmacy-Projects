/*
Project: Vancomycin AKI Monitoring (Portfolio / De-identified)
Purpose: Derive first/last administration timestamps for each encounter and identify therapy courses.
Inputs (logical): pharmacy.vanco_iv_administrations
Outputs: analytics.vanco_first_last_dates

Privacy & portability:
- Schema/table names are anonymized; logic preserved.
- No PHI included in this portfolio version.
- Component codes are retained as examples; map to your local dictionary as needed.

Parameters / assumptions:
  - @gap_days (default 2) to split therapy courses
  - @adult_age (default 18) if you apply age filter upstream
*/

/*
Legacy header (kept for provenance; identifiers generalized):
/************************************************************************************************************************************************************************************************************
* Description: First and last vancomycin administrations for each course of therapy. 
* Author: Rebecca Mead
* SAM Date: 08/18/2023
************************************************************************************************************************************************************************************************************
** Change History
************************************************************************************************************************************************************************************************************
**PR    Date                Author               Description
**1	      11/10/2023    Rebecca Mead   Added MAX() to ROW_NUMBER() OVER (PARTITION BY fl.encounter_key ORDER BY fl.first_admin_date) AS TherapyCourseNUM
************************************************************************************************************************************************************************************************************/
*/

WITH
  -- Get all distinct admin dates by encounter_key
dates AS
	(
	SELECT DISTINCT
		encounter_key
		,CONVERT(DATE,(admin_ts)) AS AdministrationDT
	FROM pharmacy.vanco_iv_administrations
	),

-- Generate "groups" of admin dates by subtracting the
-- date's row number (no gaps) from the admin dates itself
-- (with potential gaps). Whenever there is a gap,
-- there will be a new group
groups AS
	(
	SELECT
		encounter_key
		,ROW_NUMBER() OVER (PARTITION BY encounter_key ORDER BY AdministrationDT) AS rn
		,DATEADD(DAY, -ROW_NUMBER() OVER (PARTITION BY encounter_key ORDER BY AdministrationDT), AdministrationDT) AS grp
		,AdministrationDT
	FROM dates		
	),

--First and Last Admin dates for all courses of therapy
FirstLast AS
	(
	SELECT
		encounter_key
		,MIN(AdministrationDT) AS first_admin_date
		,MAX(AdministrationDT) AS LastAdministrationDT
		,COUNT(*) AS ConsecutiveAdminDays
	FROM groups

	GROUP BY encounter_key, grp
	)

--First and Last Admin dates for all courses of therapy
--Adding Date Time back in

SELECT 
	fl.encounter_key
	,fl.first_admin_date
	,MIN(iv1.admin_ts) AS first_admin_ts
	,fl.LastAdministrationDT
	,MAX(iv2.admin_ts) AS last_admin_ts
	,fl.ConsecutiveAdminDays
	,ROW_NUMBER() OVER (PARTITION BY fl.encounter_key ORDER BY fl.first_admin_date) AS TherapyCourseNUM
FROM 
	FirstLast fl
INNER JOIN pharmacy.vanco_iv_administrations iv1
	ON fl.encounter_key = iv1.encounter_key
	AND fl.first_admin_date = CONVERT(DATE,(iv1.admin_ts))
INNER JOIN pharmacy.vanco_iv_administrations iv2
	ON fl.encounter_key = iv2.encounter_key
	AND fl.LastAdministrationDT = CONVERT(DATE,(iv2.admin_ts))
GROUP BY 
	 fl.encounter_key
	 ,fl.first_admin_date
	 ,fl.LastAdministrationDT

	 ,fl.ConsecutiveAdminDays
