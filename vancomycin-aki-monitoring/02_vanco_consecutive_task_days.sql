/*
Project: Vancomycin AKI Monitoring (Portfolio / De-identified)
Purpose: Compute consecutive days where pharmacy vancomycin tasks fired and were completed per encounter.
Inputs (logical): pharmacy.workload_productivity, pharmacy.vanco_iv_administrations
Outputs: analytics.vanco_consecutive_task_days

Privacy & portability:
- Schema/table names are anonymized; logic preserved.
- No PHI included in this portfolio version.
- Component codes are retained as examples; map to your local dictionary as needed.

Parameters / assumptions:
  - @task_code (example in script)
  - @status_completed (example in script)
*/

/*
Legacy header (kept for provenance; identifiers generalized):
/************************************************************************************************************************************************************************************************************
* Description: Consecutive days of pharmacy vancomycin tasks firing and being completed.
* SAM Date: 08/18/2023
************************************************************************************************************************************************************************************************************
** Change History
************************************************************************************************************************************************************************************************************
**PR    Date            Author          Description
**1	
************************************************************************************************************************************************************************************************************/
*/

WITH Dist AS
(
    SELECT DISTINCT 
               wp.encounter_key
                ,CONVERT (DATE, wp.due_ts) AS DueDT
    FROM pharmacy.workload_productivity wp
    INNER JOIN pharmacy.vanco_iv_administrations va
    	ON wp.encounter_key = va.encounter_key
    WHERE wp.task_code = '2123619635'
      AND wp.status = 'Completed'
      AND wp.event_tag = '1 ea'
    GROUP BY 
      wp.encounter_key
      , wp.due_ts
),

 CTE AS
(   SELECT encounter_key,
            DueDT,
            GroupingSet = DATEADD(DAY, 
                                -ROW_NUMBER() OVER(PARTITION BY encounter_key 
                                                            ORDER BY DueDT), 
                                DueDT)
    FROM  Dist
)
SELECT  encounter_key,
        StartDT = MIN(DueDT),
        EndDT = MAX(DueDT),
        ConsecutiveDaysNBR = COUNT(NULLIF(encounter_key, 0))
FROM    CTE
GROUP BY 
   encounter_key
   ,GroupingSet
ORDER BY encounter_key
  ,StartDT;
