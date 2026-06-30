WITH hosp_drugs AS(
    SELECT
        pr.patient_amka AS patient,
        pr.hosp_entry_date AS entdate,
        ds.substance_id AS sub
    FROM prescription pr
    JOIN drug_substance ds ON pr.drug_id = ds.drug_id
)
SELECT 
    hd1.sub AS 'Ουσία_1',
    hd2.sub AS 'Ουσία_2',
    count(*) AS 'Συχνότητα Εμφάνισης'
FROM hosp_drugs hd1
JOIN hosp_drugs hd2 ON hd1.patient = hd2.patient AND hd1.entdate = hd2.entdate AND hd1.sub < hd2.sub
GROUP BY hd1.sub, hd2.sub
ORDER BY `Συχνότητα Εμφάνισης` desc
LIMIT 3;