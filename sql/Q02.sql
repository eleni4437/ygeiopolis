SELECT
    s.amka,
    s.first_name,
    s.last_name,
    d.speciality,
    d.doc_rank,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM shift_staff ss
            WHERE ss.staff_amka = d.amka
              AND YEAR(ss.date) = YEAR(CURDATE())
        ) THEN 'Ναι'
        ELSE 'Όχι'
    END AS eixe_efimeria_fetos,
    COUNT(pr.procedure_id) AS epemvaseis_os_kyrios_xeirourgos
FROM doctor d
JOIN staff s ON s.amka = d.amka
LEFT JOIN `procedure` pr ON pr.main_surgeon_amka = d.amka
AND YEAR(pr.entry_date) = YEAR(CURDATE()) 
WHERE d.speciality = 'ΚΑΡΔΙΟΛΟΓΙΑ'
GROUP BY
    s.amka;