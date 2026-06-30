WITH yearly_patients AS (
    SELECT
        h.patient_amka,
        p.first_name,
        p.last_name,
        year(h.entry_date) AS hosp_year,
        sum(datediff(h.exit_date, h.entry_date)) AS total_days
    FROM hospitalization h
    JOIN patient p ON h.patient_amka = p.amka
    WHERE h.exit_date IS NOT NULL
    GROUP BY h.patient_amka, hosp_year
    HAVING total_days > 15    
),
shared AS (
    SELECT 
        hosp_year AS hosp_year,
        total_days
     FROM yearly_patients
     GROUP BY hosp_year, total_days
     HAVING count(patient_amka) > 1
)
SELECT
    yp.patient_amka,
    yp.last_name AS 'Επίθετο',
    yp.first_name AS 'Όνομα',
    yp.hosp_year AS 'Έτος',
    yp.total_days AS 'Διάρκεια Παραμονής'
FROM yearly_patients yp
JOIN shared sh ON yp.hosp_year = sh.hosp_year AND yp.total_days = sh.total_days
ORDER BY yp.hosp_year desc, yp.total_days desc, yp.last_name;