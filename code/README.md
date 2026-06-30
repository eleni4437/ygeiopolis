# Υγειόπολις - Σύστημα Διαχείρισης Νοσοκομείου

## Πώς να τρέξεις

### Επιλογή Α: Docker (Συνιστάται)

1. Βεβαιώσου ότι το XAMPP τρέχει και η βάση `ygeiopolis` είναι φορτωμένη.
2. Άνοιξε terminal στον φάκελο `ygeipolis`:
```
docker compose up --build
```
3. Άνοιξε browser: http://localhost:5000

### Επιλογή Β: Python απευθείας

1. Εγκατάστησε Python 3.10+
2. ```
   pip install -r requirements.txt
   ```
3. Ρύθμισε το `.env` (host, port, user, password)
4. ```
   python app.py
   ```
5. Άνοιξε browser: http://localhost:5000

## Ρυθμίσεις .env

```
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=        # άδειο για XAMPP
DB_NAME=ygeiopolis
```

## Σελίδες

| Σελίδα | URL |
|--------|-----|
| Dashboard | / |
| Ασθενείς | /patients |
| Triage | /triage |
| Νοσηλείες | /hospitalizations |
| Συνταγές | /prescriptions |
| Εργαστηριακές | /lab-tests |
| Χειρουργεία | /procedures |
| Προσωπικό | /staff |
| Εφημερίες | /shifts |
| Τμήματα | /departments |
| Αξιολογήσεις | /evaluations |
| Στατιστικά | /reports |
