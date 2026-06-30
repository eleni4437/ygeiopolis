WITH young_docs as (        
    SELECT 
        s.first_name AS 'Όνομα',
        s.last_name AS 'Επώνυμο',
        s.age AS 'Ηλικία',
        COUNT(p.procedure_id) AS most_procs
    FROM `procedure` p
    JOIN procedures ps ON p.procedure_id = ps.procedure_id
    JOIN staff s ON p.main_surgeon_amka = s.amka
    JOIN doctor d ON s.amka = d.amka
    WHERE s.age < 35 
    AND ps.type = 'Χειρουργική'
    GROUP BY s.amka
)
SELECT * FROM young_docs
WHERE most_procs = (SELECT MAX(most_procs) FROM young_docs);
