WITH RECURSIVE ierarxia AS (
SELECT 
    d.amka AS amka_iatrou,
    s.first_name AS onoma_iatrou,
    s.last_name AS epwnymo_iatrou,
    d.doc_rank AS bathmida_iatrou,
    d.supervisor_amka AS amka_epopti,
    d.amka AS arxikos_iatros,
    0 AS epipedo
FROM doctor d
JOIN staff s ON d.amka = s.amka
WHERE d.supervisor_amka IS NOT NULL

UNION ALL

SELECT
    d2.amka AS amka_iatrou,
    s2.first_name AS onoma_iatrou,
    s2.last_name AS epwnymo_iatrou,
    d2.doc_rank AS bathmida_iatrou,
    d2.supervisor_amka AS amka_epopti,
    ier.arxikos_iatros AS arxikos_iatros,
    ier.epipedo+1 AS epipedo
FROM doctor d2
JOIN staff s2 ON d2.amka = s2.amka
JOIN ierarxia ier ON d2.amka = ier.amka_epopti
WHERE ier.amka_epopti IS NOT NULL
)
SELECT 
    s1.last_name AS 'Επώνυμο (αρχικού)',
    s1.first_name AS 'Όνομα',
    d1.doc_rank AS 'Βαθμίδα',
    ier.epipedo AS 'Επίπεδο Εποπτείας',
    ier.onoma_iatrou AS 'Όνομα (επόπτη)',
    ier.epwnymo_iatrou AS 'Επώνυμο',
    ier.bathmida_iatrou AS 'Βαθμίδα'
FROM ierarxia ier 
JOIN doctor d1 ON ier.arxikos_iatros = d1.amka
JOIN staff s1 ON ier.arxikos_iatros = s1.amka
WHERE ier.epipedo > 0
ORDER BY s1.last_name, ier.epipedo;