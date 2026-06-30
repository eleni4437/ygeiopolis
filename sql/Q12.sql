SELECT 
    ss.dept_name AS 'Τμήμα',
    ss.`type` AS 'Βάρδια',
    CONCAT(MIN(ss.`date`), ' έως ', MAX(ss.`date`)) AS 'Εβδομάδα',
    s.staff_type AS 'Κλάδος Προσωπικού',
    COALESCE(d.speciality, n.`rank`, p.`role`, 'Άγνωστο') AS 'Υποκλάδος',    
    COUNT(ss.staff_amka) AS 'Απαιτούμενο Προσωπικό'    
FROM shift_staff ss
JOIN staff s ON ss.staff_amka = s.amka
LEFT JOIN doctor d ON s.amka = d.amka
LEFT JOIN nurse n ON s.amka = n.amka
LEFT JOIN personel p ON s.amka = p.amka 
WHERE ss.`date` BETWEEN '2026-05-11' AND '2026-05-17'
GROUP BY 
    ss.dept_name, 
    ss.`type`, 
    s.staff_type, 
    COALESCE(d.speciality, n.`rank`, p.`role`, 'Άγνωστο')
ORDER BY 
    ss.dept_name ASC, 
    ss.`type` ASC, 
    COUNT(ss.staff_amka) DESC;