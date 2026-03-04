# SQL Pharmacy Analytics Projects

Portfolio SQL projects demonstrating real-world **clinical and pharmacy performance improvement analytics** in a health system environment.

These projects showcase techniques used to transform raw EHR data into **clinically meaningful metrics and operational insights** supporting pharmacy leadership, clinical teams, and performance improvement initiatives.

The SQL logic has been **anonymized and generalized for portfolio use**. Schema names, identifiers, and environment-specific references have been replaced while preserving the analytic approach and query logic.

---

# Projects

## Kcentra Flat Dosing Evaluation

Evaluation of dosing outcomes for **4-factor prothrombin complex concentrate (Kcentra)**.

**Objective**

Assess clinical outcomes and dosing patterns associated with Kcentra administration using lab results and dosing metrics.

**Key Analytic Components**

* Cohort identification of Kcentra administrations
* Weight-based dosing extraction
* Lab result capture in defined pre/post administration windows
* Outcome metric construction at the encounter level
* Aggregated dosing metrics for operational reporting

**Techniques Demonstrated**

* Complex cohort construction using CTEs
* Time-windowed clinical lab extraction
* Encounter-level metric tables
* Modular SQL pipeline design

📁 `kcentra-flat-dosing-evaluation/`

---

## Vancomycin AKI Monitoring

Analysis of **vancomycin therapy and kidney injury risk indicators** using laboratory results and medication administration data.

**Objective**

Develop an analytic dataset to evaluate renal function trends and potential **acute kidney injury (AKI)** indicators during vancomycin therapy.

**Key Analytic Components**

* Identification of vancomycin therapy courses
* Determination of first and last administration dates
* Consecutive therapy day calculations
* Extraction of pre/post therapy lab results
* Serum creatinine baseline identification
* Vancomycin level monitoring
* Final AKI monitoring dataset

**Techniques Demonstrated**

* Clinical time-window logic
* Multi-stage analytic table pipelines
* Medication therapy course identification
* Laboratory trend analysis

📁 `vancomycin-aki-monitoring/`

---

# Skills Demonstrated

* SQL for healthcare analytics
* EHR data modeling
* Clinical metric development
* Time-series clinical data analysis
* Pharmacy performance improvement analytics
* Modular analytics pipeline design

---

# Data Privacy

All SQL examples have been **de-identified and generalized**.
No protected health information (PHI) or proprietary system details are included.

---

# Author

Rebecca Faye Mee, MPH
Healthcare Data & Analytics Leader

Specializing in:

* Healthcare analytics
* Pharmacy data analytics
* Performance improvement analytics
* Clinical data modeling

