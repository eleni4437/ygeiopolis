SELECT
    a.substance_id,
    s.name AS drastiki_ousia,
    COUNT(DISTINCT a.patient_amka) AS arithmos_allergikon_asthenwn,
    COUNT(DISTINCT ds.drug_id) AS arithmos_farmakon
FROM active_substance s
LEFT JOIN allergy a  ON a.substance_id  = s.substance_id
LEFT JOIN drug_substance ds ON ds.substance_id = s.substance_id
GROUP BY s.substance_id
ORDER BY arithmos_allergikon_asthenwn DESC;