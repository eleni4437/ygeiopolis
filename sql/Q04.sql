-- SET PROFILING = 1;
SELECT
    ed.doctor_amka AS 'ΑΜΚΑ γιατρού',
    s.first_name AS 'Όνομα',
    s.last_name AS 'Επώνυμο',
    AVG(ed.medical_care) AS 'Μέσος όρος φροντίδας',
    AVG(eh.overall_experience) AS 'Συνολική εντύπωση'
FROM evaluation_doctor ed
JOIN evaluation_hospital eh 
    ON ed.patient_amka = eh.patient_amka
    AND ed.entry_date = eh.entry_date 
JOIN staff s ON ed.doctor_amka = s.amka
WHERE doctor_amka = '12127283498'
GROUP BY ed.doctor_amka;
-- SHOW PROFILES;