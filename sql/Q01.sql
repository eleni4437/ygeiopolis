WITH hosp_costs AS (
    SELECT 
        h.dept_name,
        YEAR(IFNULL(h.exit_date, h.entry_date)) AS eval_year,
        h.ken_code,
        p.insurance,
        h.patient_amka,
        h.entry_date,
        k.basic_cost AS base_ken_cost,
        h.cost AS total_hosp_cost,
        (h.cost - k.basic_cost) AS extra_ken_cost
    FROM `hospitalization` h
    JOIN `patient` p ON h.patient_amka = p.amka
    JOIN `ken` k ON h.ken_code = k.ken_code
    WHERE h.cost IS NOT NULL
),
proc_costs AS (
    SELECT patient_amka, entry_date, SUM(cost) AS total_proc_cost
    FROM `procedure`
    GROUP BY patient_amka, entry_date
),
lab_costs AS (
    SELECT patient_amka, entry_date, SUM(cost) AS total_lab_cost
    FROM `lab_test`
    GROUP BY patient_amka, entry_date
)
SELECT 
    hc.dept_name AS 'Τμήμα',
    hc.eval_year AS 'Έτος',
    hc.ken_code AS 'Κωδικός ΚΕΝ',
    hc.insurance AS 'Ασφαλιστικός Φορέας',
    COUNT(*) AS 'Πλήθος Νοσηλειών',
    SUM(hc.base_ken_cost) AS 'Συνολικό Βασικό Κόστος ΚΕΝ',
    SUM(hc.extra_ken_cost) AS 'Πρόσθετη Χρέωση (Υπέρβαση ΜΔΝ)',
    SUM(IFNULL(pc.total_proc_cost, 0)) AS 'Έσοδα Χειρουργείων',
    SUM(IFNULL(lc.total_lab_cost, 0)) AS 'Έσοδα Εργαστηριακών',
    SUM(hc.total_hosp_cost + IFNULL(pc.total_proc_cost, 0) + IFNULL(lc.total_lab_cost, 0)) AS 'Συνολικά Έσοδα'
FROM hosp_costs hc
LEFT JOIN proc_costs pc ON hc.patient_amka = pc.patient_amka AND hc.entry_date = pc.entry_date
LEFT JOIN lab_costs lc ON hc.patient_amka = lc.patient_amka AND hc.entry_date = lc.entry_date
GROUP BY 
    hc.dept_name, 
    hc.eval_year, 
    hc.ken_code, 
    hc.insurance
ORDER BY 
    hc.dept_name ASC, 
    hc.eval_year DESC, 
    'Συνολικά Έσοδα' DESC;