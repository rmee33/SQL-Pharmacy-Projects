/*
Project: Vancomycin AKI Monitoring (Portfolio / De-identified)
Purpose: Create the final encounter-level table used to classify AKI risk/status for adult IV vancomycin patients (first therapy course).
Inputs (logical): analytics.vanco_first_last_dates, analytics.vanco_consecutive_task_days, analytics.vanco_pre_medians, analytics.vanco_first_scr_24h, analytics.vanco_levels_counts, analytics.vanco_labs_after_*
Outputs: analytics.vanco_aki_final

Privacy & portability:
- Schema/table names are anonymized; logic preserved.
- No PHI included in this portfolio version.
- Component codes are retained as examples; map to your local dictionary as needed.

Parameters / assumptions:
  - @adult_age = 18
  - @scr_component_code (example in script)
  - @aki_thresholds (documented in docs)
*/

/*
Legacy header (kept for provenance; identifiers generalized):
/************************************************************************************************************************************************************************************************************
* Description: The final table to assess the AKI status for patients 18 and older that have received IV vancomycin, using data elements for the first course of therapy.  
* The table contains:
    	The first and last dates and times of vancomycin administration.
    	Consecutive days of vancomycin administration.
    	Consecutive days of pharmacy vancomycin tasks firing and being completed.
    	Median lab values prior to the first dose of vancomycin.
    	The first SCr lab result to take place between 12 hours before or 12 hours after the first dose of vancomycin.
    	The number of levels (Vancomycin Rn, Vancomycin Pk, Vancomycin Tr) taken before and after the first dose of vancomycin.
    	Maximum and minimum CrCl lab results after the first dose of vancomycin.
    	Max SCr lab result after the first dose of vancomycin, the number of times that the max value was reached, and the date and time of the lab result(s)
* Author: Rebecca Mead
* SAM Date: 08/18/2023
************************************************************************************************************************************************************************************************************
** Change History
************************************************************************************************************************************************************************************************************
**PR    Date            Author          Description
**1	
************************************************************************************************************************************************************************************************************/
*/

WITH CTE2 AS(
	SELECT 
		encounter_key
		,StartDT
		,EndDT
		,ConsecutiveDaysNBR
		,ROW_NUMBER() OVER(PARTITION BY encounter_key ORDER BY StartDT) AS RN
	FROM pharmacy.VancomycinTaskDays
	GROUP BY
		encounter_key
		,StartDT
		,EndDT
		,ConsecutiveDaysNBR
		)

SELECT 
	iv.encounter_key
	,iv.PatientID
	,se.Fin
	,iv.EncounterLocationDSC
	,iv.discharge_ts
	,pp.BirthDTS
  ,datediff(YY,pp.BirthDTS,iv.discharge_ts) as AgeAtDischarge
	,pp.GenderDSC
  ,lv.PreLevelsTaken AS PreLevelsTakenNBR
	,lv.PostLevelsTaken AS PostLevelsTakenNBR
	,vm.PreVancMedianSCr
	,vm.PreVancMedianCrCl
  ,sr.FirstScR24HrVancoNBR
	,vd.first_admin_ts
	,vd.last_admin_ts
  ,vd.ConsecutiveAdminDays AS FirstTherapyConsecutiveDaysNBR
  ,CTE2.ConsecutiveDaysNBR AS FirstTherapyConsecutiveTaskDaysNBR
	,sc.PostVancoMaxSCr
	,sc.MaxSCrCNT
	,sc.FirstMaxSCrDTS
	,sc.LastMaxSCrDTS
	,cr.PostVancoMaxCrCl
	,cr.PostVancoMinCrCl
FROM pharmacy.vanco_iv_administrations iv
LEFT JOIN ehr.Encounter se WITH (NOLOCK) 
	ON iv.encounter_key = se.encounter_key
LEFT JOIN Shared.Person.Patient pp
	ON pp.EDWPatientID = se.EDWPatientID
LEFT JOIN analytics.vanco_pre_medians vm
	ON vm.encounter_key = iv.encounter_key
LEFT JOIN analytics.vanco_first_last_dates vd
	ON vd.encounter_key = iv.encounter_key
LEFT JOIN pharmacy.VancomycinPostMaxSCr sc
	ON sc.encounter_key = iv.encounter_key
LEFT JOIN pharmacy.VancomycinPostMaxMinCrCl cr
	ON cr.encounter_key = iv.encounter_key
LEFT JOIN analytics.vanco_levels_counts lv
   ON lv.encounter_key = iv.encounter_key
LEFT JOIN pharmacy.VancomycinFirstScR sr
  ON sr.encounter_key = iv.encounter_key
LEFT JOIN pharmacy.VancomycinTaskDays vt
  ON vt.encounter_key = iv.encounter_key
  LEFT JOIN CTE2
  ON CTE2.encounter_key = iv.encounter_key
  AND CTE2.RN = 1

WHERE datediff(YY,pp.BirthDTS,iv.discharge_ts) > 17  
AND vd.TherapyCourseNUM = 1
  GROUP BY 
  iv.encounter_key
	,iv.PatientID
	,se.Fin
	,iv.EncounterLocationDSC
	,iv.discharge_ts
	,pp.BirthDTS
  ,datediff(YY,pp.BirthDTS,iv.discharge_ts)
	,pp.GenderDSC
  ,lv.PreLevelsTaken
	,lv.PostLevelsTaken
	,vm.PreVancMedianSCr
	,vm.PreVancMedianCrCl
	,vd.first_admin_ts
	,vd.last_admin_ts
  ,vd.ConsecutiveAdminDays
  ,CTE2.ConsecutiveDaysNBR
	,sc.PostVancoMaxSCr
	,sc.MaxSCrCNT
	,sc.FirstMaxSCrDTS
	,sc.LastMaxSCrDTS
	,cr.PostVancoMaxCrCl
	,cr.PostVancoMinCrCl
  ,sr.FirstScR24HrVancoNBR
