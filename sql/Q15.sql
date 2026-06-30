WITH triage_data AS (
    SELECT 
        t.urgency_level,
        t.patient_amka,
        t.arrival_time,
        t.outcome,
        h.dept_name,
        TIMESTAMPDIFF(MINUTE, t.arrival_time, h.entry_date) AS duration
    FROM triage t
    LEFT JOIN hospitalization h 
        ON t.patient_amka = h.patient_amka 
        AND DATE(t.arrival_time) = DATE(h.entry_date)
),
per_urgency AS (
    SELECT 
        urgency_level,
        COUNT(*) AS total_cases,
        SUM(CASE WHEN outcome = 'ΝΟΣΗΛΕΙΑ' then 1 else 0 END) AS hosp_cases,
        AVG(duration) AS avg_dur
    FROM triage_data
    GROUP BY urgency_level
),
per_dept AS (
    SELECT
        urgency_level,
        dept_name,
        count(*) AS dept_cases
    FROM triage_data
    WHERE dept_name IS NOT NULL
    GROUP BY urgency_level, dept_name
),
per_dept_string AS(
    SELECT
        urgency_level,
        GROUP_CONCAT(CONCAT(dept_name, ' (', dept_cases, ') ') SEPARATOR ', ' ) AS dept_string
    FROM per_dept
    GROUP BY urgency_level
)
SELECT
    pu.urgency_level AS 'Επίπεδο Επείγοντος (1-5)',
    pu.total_cases AS 'Σύνολο Περιστατικών',
    ROUND(pu.avg_dur, 0) AS 'Μέσος Χρόνος Αναμονής (Λεπτά)',
    ROUND((pu.hosp_cases / pu.total_cases) * 100, 1) AS 'Ποσοστό Νοσηλείας (%)',
    IFNULL(pds.dept_string, 'Καμία Παραπομπή') AS 'Κατανομή Παραπομπών ανά Τμήμα'
FROM per_urgency pu
LEFT JOIN per_dept_string pds ON pu.urgency_level = pds.urgency_level
ORDER BY pu.urgency_level asc;