WITH curyear_surgeons AS (
    SELECT 
        d.amka,
        count(*) as total_procs
    FROM doctor d
    LEFT JOIN `procedure` pr ON d.amka = pr.main_surgeon_amka and year(entry_date) = year(curdate())
    GROUP BY d.amka
    ORDER BY total_procs desc
),
max_procs AS (
    select max(total_procs) AS max_tots
    from curyear_surgeons
)
SELECT
    cs.amka,
    s.last_name AS 'Επίθετο',
    s.first_name AS 'Όνομα',
    cs.total_procs AS 'Φετινές Επεμβάσεις'
FROM curyear_surgeons cs
JOIN staff s ON s.amka = cs.amka
CROSS JOIN max_procs mp
WHERE cs.total_procs <= mp.max_tots - 5
ORDER BY cs.total_procs desc;