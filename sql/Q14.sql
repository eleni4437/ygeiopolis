WITH diagnosis_counts AS (    
    SELECT 
        exit_diagnosis AS 'icd10',
        YEAR(entry_date) AS 'year_num',
        COUNT(*) AS 'incident_count'
    FROM hospitalization
    WHERE exit_diagnosis IS NOT NULL 
    GROUP BY exit_diagnosis, YEAR(entry_date)
    HAVING COUNT(*) >= 5 
)
SELECT 
    dc1.icd10 AS 'Κωδικός ICD-10',
    dc1.year_num AS 'Έτος Α',
    dc2.year_num AS 'Έτος Β (Συνεχόμενο)',
    dc1.incident_count AS 'Πλήθος Περιστατικών'
FROM diagnosis_counts dc1
JOIN diagnosis_counts dc2 ON dc1.icd10 = dc2.icd10 
    AND dc2.year_num = dc1.year_num + 1 
WHERE dc1.incident_count = dc2.incident_count;