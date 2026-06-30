set @dept = 'ΠΑΘΟΛΟΓΙΑ';
set @date = '2025-05-05';

WITH dept_staff AS(
    SELECT amka, dept_name FROM nurse
    UNION
    SELECT amka, dept_name FROM personel
    UNION
    SELECT doc_amka AS amka, dept_name FROM department_doctor
)
SELECT
    s.amka,
    s.last_name AS 'Επίθετο',
    s.first_name AS 'Όνομα',
    s.staff_type AS 'Ειδικότητα'
FROM staff s
JOIN dept_staff ds ON s.amka = ds.amka AND ds.dept_name = @dept 
LEFT JOIN shift_staff ss ON s.amka = ss.staff_amka AND ss.date = @date
WHERE ss.staff_amka IS NULL
ORDER BY s.staff_type, s.last_name;