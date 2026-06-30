SELECT 
    p.amka,
    p.first_name AS 'Όνομα',
    p.last_name AS 'Επώνυμο',
    h.dept_name AS 'Τμήμα',
    COUNT(*) AS 'Πλήθος Νοσηλειών',
    SUM(h.cost) AS 'Συνολικό Κόστος'
FROM hospitalization h
JOIN patient p ON h.patient_amka = p.amka
GROUP BY p.amka, h.dept_name
HAVING COUNT(*) > 3
ORDER BY 'Συνολικό Κόστος' DESC;
