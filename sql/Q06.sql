-- SET PROFILING = 1;
SELECT
    h.entry_date AS 'Ημερομηνία εισαγωγής',
    h.exit_date AS 'Ημερομηνία εξόδου',
    DATEDIFF(h.exit_date, h.entry_date) AS 'Ημέρες νοσηλείας',
    h.dept_name AS 'Τμήμα',
    h.room_number AS 'Αριθμός δωματίου',
    h.entry_diagnosis AS 'ICD εισαγωγής',
    d_in.description AS 'Διάγνωση εισαγωγής',
    h.exit_diagnosis AS 'ICD εξόδου',
    d_out.description AS 'Διάγνωση εξόδου',
    h.cost AS 'Συνολικό κόστος',
    AVG(eh.overall_experience) AS 'Μέσος όρος αξιολόγησης'
FROM hospitalization h 
JOIN diagnosis d_in 
    ON h.entry_diagnosis = d_in.ICD
LEFT JOIN diagnosis d_out
    ON h.exit_diagnosis = d_out.ICD
LEFT JOIN evaluation_hospital eh 
    ON h.patient_amka = eh.patient_amka
    AND h.entry_date = eh.entry_date
WHERE h.patient_amka = '26124400192'
GROUP BY h.entry_date;
-- SHOW PROFILES;