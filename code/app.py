from flask import Flask, render_template, request, redirect, url_for, flash
from db import query, execute
import os

app = Flask(__name__)
app.secret_key = "ygeiopolis_secret_2024"


# ── Dashboard ──────────────────────────────────────────────────────────────────
@app.route("/")
def dashboard():
    stats = {
        "patients": query("SELECT COUNT(*) as n FROM patient", fetchone=True)["n"],
        "staff": query("SELECT COUNT(*) as n FROM staff", fetchone=True)["n"],
        "doctors": query("SELECT COUNT(*) as n FROM doctor", fetchone=True)["n"],
        "active_hosp": query("SELECT COUNT(*) as n FROM hospitalization WHERE exit_date IS NULL", fetchone=True)["n"],
        "departments": query("SELECT COUNT(*) as n FROM department", fetchone=True)["n"],
        "triage_waiting": query("SELECT COUNT(*) as n FROM triage WHERE status='ΑΝΑΜΟΝΗ'", fetchone=True)["n"],
    }
    recent_hosp = query("""
        SELECT h.entry_date, p.first_name, p.last_name, h.dept_name, h.room_number
        FROM hospitalization h JOIN patient p ON p.amka=h.patient_amka
        ORDER BY h.entry_date DESC LIMIT 5
    """)
    top_dept = query("""
        SELECT dept_name, COUNT(*) as total
        FROM hospitalization GROUP BY dept_name ORDER BY total DESC LIMIT 5
    """)
    return render_template("dashboard.html", stats=stats,
                           recent_hosp=recent_hosp, top_dept=top_dept)


# ── Patients ───────────────────────────────────────────────────────────────────
@app.route("/patients")
def patients():
    search = request.args.get("q", "")
    if search:
        rows = query("""
            SELECT * FROM patient
            WHERE first_name LIKE %s OR last_name LIKE %s OR amka LIKE %s
            ORDER BY last_name
        """, (f"%{search}%", f"%{search}%", f"%{search}%"))
    else:
        rows = query("SELECT * FROM patient ORDER BY last_name LIMIT 200")
    return render_template("patients/list.html", patients=rows, search=search)


@app.route("/patients/<amka>")
def patient_view(amka):
    p = query("SELECT * FROM patient WHERE amka=%s", (amka,), fetchone=True)
    if not p:
        flash("Ο ασθενής δεν βρέθηκε.", "danger")
        return redirect(url_for("patients"))
    hosp = query("""
        SELECT h.*, d.description as diag_in, d2.description as diag_out
        FROM hospitalization h
        LEFT JOIN diagnosis d ON d.ICD=h.entry_diagnosis
        LEFT JOIN diagnosis d2 ON d2.ICD=h.exit_diagnosis
        WHERE h.patient_amka=%s ORDER BY h.entry_date DESC
    """, (amka,))
    prescriptions = query("""
        SELECT pr.*, dr.name as drug_name, s.first_name, s.last_name
        FROM prescription pr
        JOIN drug dr ON dr.drug_id=pr.drug_id
        JOIN staff s ON s.amka=pr.doc_amka
        WHERE pr.patient_amka=%s ORDER BY pr.starting_date DESC
    """, (amka,))
    labs = query("""
        SELECT lt.*, lts.description, s.first_name, s.last_name
        FROM lab_test lt
        JOIN lab_tests lts ON lts.lab_id=lt.lab_id
        JOIN staff s ON s.amka=lt.doctor_amka
        WHERE lt.patient_amka=%s ORDER BY lt.date DESC
    """, (amka,))
    allergies = query("""
        SELECT a.*, sub.name as substance
        FROM allergy a JOIN active_substance sub ON sub.substance_id=a.substance_id
        WHERE a.patient_amka=%s
    """, (amka,))
    triage = query("SELECT * FROM triage WHERE patient_amka=%s ORDER BY arrival_time DESC", (amka,))
    return render_template("patients/view.html", patient=p, hosp=hosp,
                           prescriptions=prescriptions, labs=labs,
                           allergies=allergies, triage=triage)


@app.route("/patients/new", methods=["GET", "POST"])
def patient_new():
    if request.method == "POST":
        f = request.form
        try:
            execute("""
                INSERT INTO patient (amka,first_name,last_name,patronym,age,sex,weight,height,
                    address,phone_number,email,job,citizenship,emergency_contact,insurance)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, (f["amka"], f["first_name"], f["last_name"], f["patronym"],
                  f["age"], f["sex"], f["weight"], f["height"],
                  f["address"], f["phone_number"], f["email"],
                  f["job"], f["citizenship"], f["emergency_contact"], f["insurance"]))
            flash("Ο ασθενής καταχωρήθηκε.", "success")
            return redirect(url_for("patient_view", amka=f["amka"]))
        except Exception as e:
            flash(f"Σφάλμα: {e}", "danger")
    return render_template("patients/form.html", patient=None)


@app.route("/patients/<amka>/edit", methods=["GET", "POST"])
def patient_edit(amka):
    p = query("SELECT * FROM patient WHERE amka=%s", (amka,), fetchone=True)
    if not p:
        return redirect(url_for("patients"))
    if request.method == "POST":
        f = request.form
        try:
            execute("""
                UPDATE patient SET first_name=%s,last_name=%s,patronym=%s,age=%s,sex=%s,
                    weight=%s,height=%s,address=%s,phone_number=%s,email=%s,
                    job=%s,citizenship=%s,emergency_contact=%s,insurance=%s
                WHERE amka=%s
            """, (f["first_name"], f["last_name"], f["patronym"], f["age"], f["sex"],
                  f["weight"], f["height"], f["address"], f["phone_number"], f["email"],
                  f["job"], f["citizenship"], f["emergency_contact"], f["insurance"], amka))
            flash("Τα στοιχεία ενημερώθηκαν.", "success")
            return redirect(url_for("patient_view", amka=amka))
        except Exception as e:
            flash(f"Σφάλμα: {e}", "danger")
    return render_template("patients/form.html", patient=p)


# ── Staff / Doctors / Nurses ───────────────────────────────────────────────────
@app.route("/staff")
def staff():
    search = request.args.get("q", "")
    role_filter = request.args.get("role", "")
    sql = "SELECT * FROM staff WHERE 1=1"
    args = []
    if search:
        sql += " AND (first_name LIKE %s OR last_name LIKE %s OR amka LIKE %s)"
        args += [f"%{search}%", f"%{search}%", f"%{search}%"]
    if role_filter:
        sql += " AND staff_type=%s"
        args.append(role_filter)
    sql += " ORDER BY last_name LIMIT 200"
    rows = query(sql, args)
    return render_template("staff/list.html", staff=rows, search=search, role_filter=role_filter)


@app.route("/staff/<amka>")
def staff_view(amka):
    s = query("SELECT * FROM staff WHERE amka=%s", (amka,), fetchone=True)
    if not s:
        flash("Το μέλος προσωπικού δεν βρέθηκε.", "danger")
        return redirect(url_for("staff"))
    doctor = query("SELECT * FROM doctor WHERE amka=%s", (amka,), fetchone=True)
    nurse = query("SELECT * FROM nurse WHERE amka=%s", (amka,), fetchone=True)
    depts = query("""
        SELECT dept_name FROM department_doctor WHERE doc_amka=%s
    """, (amka,)) if doctor else []
    shifts = query("""
        SELECT * FROM shift_staff WHERE staff_amka=%s ORDER BY date DESC LIMIT 20
    """, (amka,))
    evals = query("""
        SELECT e.*, p.first_name, p.last_name
        FROM evaluation_doctor e JOIN patient p ON p.amka=e.patient_amka
        WHERE e.doctor_amka=%s ORDER BY e.eval_date DESC LIMIT 10
    """, (amka,)) if doctor else []
    return render_template("staff/view.html", member=s, doctor=doctor,
                           nurse=nurse, depts=depts, shifts=shifts, evals=evals)


# ── Hospitalizations ───────────────────────────────────────────────────────────
@app.route("/hospitalizations")
def hospitalizations():
    active_only = request.args.get("active", "0") == "1"
    dept_filter = request.args.get("dept", "")
    sql = """
        SELECT h.*, p.first_name, p.last_name, p.amka as p_amka
        FROM hospitalization h JOIN patient p ON p.amka=h.patient_amka
        WHERE 1=1
    """
    args = []
    if active_only:
        sql += " AND h.exit_date IS NULL"
    if dept_filter:
        sql += " AND h.dept_name=%s"
        args.append(dept_filter)
    sql += " ORDER BY h.entry_date DESC LIMIT 300"
    rows = query(sql, args)
    depts = query("SELECT dept_name FROM department ORDER BY dept_name")
    return render_template("hospitalizations/list.html", rows=rows,
                           depts=depts, active_only=active_only, dept_filter=dept_filter)


@app.route("/hospitalizations/new", methods=["GET", "POST"])
def hospitalization_new():
    if request.method == "POST":
        f = request.form
        try:
            execute("""
                INSERT INTO hospitalization
                    (patient_amka,entry_date,dept_name,room_number,entry_diagnosis,ken_code)
                VALUES (%s,%s,%s,%s,%s,%s)
            """, (f["patient_amka"], f["entry_date"], f["dept_name"],
                  f["room_number"], f["entry_diagnosis"], f["ken_code"]))
            flash("Η νοσηλεία καταχωρήθηκε.", "success")
            return redirect(url_for("hospitalizations"))
        except Exception as e:
            flash(f"Σφάλμα: {e}", "danger")
    patients_list = query("SELECT amka,first_name,last_name FROM patient ORDER BY last_name")
    depts = query("SELECT dept_name FROM department ORDER BY dept_name")
    diagnoses = query("SELECT ICD,description FROM diagnosis ORDER BY ICD LIMIT 500")
    ken_list = query("SELECT ken_code,description FROM ken ORDER BY ken_code")
    rooms = query("SELECT dept_name,room_number,room_type FROM room WHERE status='ΔΙΑΘΕΣΙΜΟ' ORDER BY dept_name,room_number")
    return render_template("hospitalizations/form.html",
                           patients_list=patients_list, depts=depts,
                           diagnoses=diagnoses, ken_list=ken_list, rooms=rooms)


@app.route("/hospitalizations/<amka>/<entry_date>/discharge", methods=["POST"])
def discharge(amka, entry_date):
    f = request.form
    try:
        execute("""
            UPDATE hospitalization SET exit_date=%s, exit_diagnosis=%s, cost=%s
            WHERE patient_amka=%s AND entry_date=%s
        """, (f["exit_date"], f["exit_diagnosis"], f["cost"], amka, entry_date))
        flash("Η εξιτήριο καταχωρήθηκε.", "success")
    except Exception as e:
        flash(f"Σφάλμα: {e}", "danger")
    return redirect(url_for("hospitalizations"))


# ── Triage ─────────────────────────────────────────────────────────────────────
@app.route("/triage")
def triage():
    rows = query("""
        SELECT t.*, p.first_name, p.last_name, s.first_name as n_fn, s.last_name as n_ln
        FROM triage t
        JOIN patient p ON p.amka=t.patient_amka
        JOIN staff s ON s.amka=t.nurse_amka
        ORDER BY t.urgency_level DESC, t.arrival_time
    """)
    return render_template("triage/list.html", rows=rows)


@app.route("/triage/waiting")
def triage_waiting():
    waiting = query("""
        SELECT t.*, p.first_name, p.last_name, p.age, p.sex,
               s.first_name as n_fn, s.last_name as n_ln,
               TIMESTAMPDIFF(MINUTE, t.arrival_time, NOW()) as wait_minutes
        FROM triage t
        JOIN patient p ON p.amka=t.patient_amka
        JOIN staff s ON s.amka=t.nurse_amka
        WHERE t.status NOT IN ('ΟΛΟΚΛΗΡΩΘΗΚΕ','ΣΕ ΕΞΕΛΙΞΗ')
        ORDER BY t.urgency_level DESC, t.arrival_time
    """)
    in_progress = query("""
        SELECT t.*, p.first_name, p.last_name, p.age, p.sex,
               s.first_name as n_fn, s.last_name as n_ln,
               TIMESTAMPDIFF(MINUTE, t.arrival_time, NOW()) as wait_minutes
        FROM triage t
        JOIN patient p ON p.amka=t.patient_amka
        JOIN staff s ON s.amka=t.nurse_amka
        WHERE t.status = 'ΣΕ ΕΞΕΛΙΞΗ'
        ORDER BY t.urgency_level DESC, t.arrival_time
    """)
    stats = {
        "waiting": len(waiting),
        "in_progress": len(in_progress),
        "critical": sum(1 for r in waiting if r["urgency_level"] >= 4),
    }
    return render_template("triage/waiting.html", waiting=waiting,
                           in_progress=in_progress, stats=stats)


@app.route("/triage/new", methods=["GET", "POST"])
def triage_new():
    if request.method == "POST":
        f = request.form
        try:
            execute("""
                INSERT INTO triage (arrival_time,patient_amka,symptoms,urgency_level,nurse_amka,status)
                VALUES (%s,%s,%s,%s,%s,'ΑΝΑΜΟΝΗ')
            """, (f["arrival_time"], f["patient_amka"], f["symptoms"],
                  f["urgency_level"], f["nurse_amka"]))
            flash("Η triage καταχωρήθηκε.", "success")
            return redirect(url_for("triage"))
        except Exception as e:
            flash(f"Σφάλμα: {e}", "danger")
    patients_list = query("SELECT amka,first_name,last_name FROM patient ORDER BY last_name")
    nurses = query("""
        SELECT s.amka,s.first_name,s.last_name FROM staff s
        JOIN nurse n ON n.amka=s.amka ORDER BY s.last_name
    """)
    return render_template("triage/form.html", patients_list=patients_list, nurses=nurses)


@app.route("/triage/update-status", methods=["POST"])
def triage_update_status():
    amka = request.form["patient_amka"]
    arrival = request.form["arrival_time"]
    status = request.form["status"]
    outcome = request.form.get("outcome", "")
    execute("""
        UPDATE triage SET status=%s, outcome=%s
        WHERE patient_amka=%s AND arrival_time=%s
    """, (status, outcome, amka, arrival))
    flash("Η κατάσταση ενημερώθηκε.", "success")
    return redirect(url_for("triage"))


# ── Prescriptions ──────────────────────────────────────────────────────────────
@app.route("/prescriptions")
def prescriptions():
    search = request.args.get("q", "")
    if search:
        rows = query("""
            SELECT pr.*, dr.name as drug_name, p.first_name, p.last_name,
                   s.first_name as d_fn, s.last_name as d_ln
            FROM prescription pr
            JOIN drug dr ON dr.drug_id=pr.drug_id
            JOIN patient p ON p.amka=pr.patient_amka
            JOIN staff s ON s.amka=pr.doc_amka
            WHERE p.last_name LIKE %s OR p.amka LIKE %s OR dr.name LIKE %s
            ORDER BY pr.starting_date DESC LIMIT 200
        """, (f"%{search}%", f"%{search}%", f"%{search}%"))
    else:
        rows = query("""
            SELECT pr.*, dr.name as drug_name, p.first_name, p.last_name,
                   s.first_name as d_fn, s.last_name as d_ln
            FROM prescription pr
            JOIN drug dr ON dr.drug_id=pr.drug_id
            JOIN patient p ON p.amka=pr.patient_amka
            JOIN staff s ON s.amka=pr.doc_amka
            ORDER BY pr.starting_date DESC LIMIT 200
        """)
    return render_template("prescriptions/list.html", rows=rows, search=search)


# ── Lab Tests ──────────────────────────────────────────────────────────────────
@app.route("/lab-tests")
def lab_tests():
    search = request.args.get("q", "")
    if search:
        rows = query("""
            SELECT lt.*, lts.description as test_name, lts.type,
                   p.first_name, p.last_name, s.first_name as d_fn, s.last_name as d_ln
            FROM lab_test lt
            JOIN lab_tests lts ON lts.lab_id=lt.lab_id
            JOIN patient p ON p.amka=lt.patient_amka
            JOIN staff s ON s.amka=lt.doctor_amka
            WHERE p.last_name LIKE %s OR lts.description LIKE %s
            ORDER BY lt.date DESC LIMIT 200
        """, (f"%{search}%", f"%{search}%"))
    else:
        rows = query("""
            SELECT lt.*, lts.description as test_name, lts.type,
                   p.first_name, p.last_name, s.first_name as d_fn, s.last_name as d_ln
            FROM lab_test lt
            JOIN lab_tests lts ON lts.lab_id=lt.lab_id
            JOIN patient p ON p.amka=lt.patient_amka
            JOIN staff s ON s.amka=lt.doctor_amka
            ORDER BY lt.date DESC LIMIT 200
        """)
    return render_template("lab_tests/list.html", rows=rows, search=search)


# ── Procedures ─────────────────────────────────────────────────────────────────
@app.route("/procedures")
def procedures():
    rows = query("""
        SELECT pr.*, prs.description as proc_name, prs.type,
               p.first_name, p.last_name,
               s.first_name as surg_fn, s.last_name as surg_ln
        FROM `procedure` pr
        JOIN procedures prs ON prs.procedure_id=pr.procedure_id
        JOIN patient p ON p.amka=pr.patient_amka
        JOIN staff s ON s.amka=pr.main_surgeon_amka
        ORDER BY pr.starting_time DESC LIMIT 200
    """)
    return render_template("procedures/list.html", rows=rows)


# ── Shifts ─────────────────────────────────────────────────────────────────────
@app.route("/shifts")
def shifts():
    dept_filter = request.args.get("dept", "")
    date_filter = request.args.get("date", "")
    sql = """
        SELECT sh.*, COUNT(ss.staff_amka) as staff_count
        FROM shift sh
        LEFT JOIN shift_staff ss ON ss.dept_name=sh.dept_name
            AND ss.date=sh.date AND ss.type=sh.type
        WHERE 1=1
    """
    args = []
    if dept_filter:
        sql += " AND sh.dept_name=%s"
        args.append(dept_filter)
    if date_filter:
        sql += " AND sh.date=%s"
        args.append(date_filter)
    sql += " GROUP BY sh.dept_name,sh.date,sh.type ORDER BY sh.date DESC,sh.dept_name LIMIT 200"
    rows = query(sql, args)
    depts = query("SELECT dept_name FROM department ORDER BY dept_name")
    return render_template("shifts/list.html", rows=rows, depts=depts,
                           dept_filter=dept_filter, date_filter=date_filter)


@app.route("/shifts/<dept>/<date>/<shift_type>")
def shift_view(dept, date, shift_type):
    shift = query("SELECT * FROM shift WHERE dept_name=%s AND date=%s AND type=%s",
                  (dept, date, shift_type), fetchone=True)
    staff_list = query("""
        SELECT ss.*, s.first_name, s.last_name, s.staff_type
        FROM shift_staff ss JOIN staff s ON s.amka=ss.staff_amka
        WHERE ss.dept_name=%s AND ss.date=%s AND ss.type=%s
    """, (dept, date, shift_type))
    return render_template("shifts/view.html", shift=shift, staff_list=staff_list)


# ── Evaluations ────────────────────────────────────────────────────────────────
@app.route("/evaluations")
def evaluations():
    doc_evals = query("""
        SELECT d.amka, s.first_name, s.last_name, d.speciality,
               AVG(e.medical_care) as avg_care,
               COUNT(e.patient_amka) as total_evals
        FROM evaluation_doctor e
        JOIN doctor d ON d.amka=e.doctor_amka
        JOIN staff s ON s.amka=d.amka
        GROUP BY d.amka, s.first_name, s.last_name, d.speciality
        ORDER BY avg_care DESC
    """)
    hosp_evals = query("""
        SELECT AVG(nursing_care) as nursing, AVG(cleanliness) as clean,
               AVG(food) as food, AVG(overall_experience) as overall,
               COUNT(*) as total
        FROM evaluation_hospital
    """, fetchone=True)
    return render_template("evaluations/list.html",
                           doc_evals=doc_evals, hosp_evals=hosp_evals)


# ── Reports ────────────────────────────────────────────────────────────────────
@app.route("/reports")
def reports():
    hosp_per_dept = query("""
        SELECT dept_name, COUNT(*) as total,
               AVG(DATEDIFF(COALESCE(exit_date, NOW()), entry_date)) as avg_days,
               AVG(cost) as avg_cost
        FROM hospitalization GROUP BY dept_name ORDER BY total DESC
    """)
    top_diagnoses = query("""
        SELECT d.ICD, d.description, COUNT(*) as total
        FROM hospitalization h JOIN diagnosis d ON d.ICD=h.entry_diagnosis
        GROUP BY d.ICD, d.description ORDER BY total DESC LIMIT 10
    """)
    monthly_admissions = query("""
        SELECT DATE_FORMAT(entry_date,'%%Y-%%m') as month, COUNT(*) as total
        FROM hospitalization
        GROUP BY month ORDER BY month DESC LIMIT 12
    """)
    top_drugs = query("""
        SELECT dr.name, COUNT(*) as prescriptions
        FROM prescription pr JOIN drug dr ON dr.drug_id=pr.drug_id
        GROUP BY dr.drug_id, dr.name ORDER BY prescriptions DESC LIMIT 10
    """)
    staff_by_type = query("""
        SELECT staff_type, COUNT(*) as total FROM staff GROUP BY staff_type
    """)
    return render_template("reports/index.html",
                           hosp_per_dept=hosp_per_dept,
                           top_diagnoses=top_diagnoses,
                           monthly_admissions=monthly_admissions,
                           top_drugs=top_drugs,
                           staff_by_type=staff_by_type)


# ── Departments ────────────────────────────────────────────────────────────────
@app.route("/departments")
def departments():
    rows = query("""
        SELECT d.*, s.first_name, s.last_name,
               COUNT(DISTINCT r.room_number) as rooms,
               COUNT(DISTINCT dd.doc_amka) as doctors
        FROM department d
        LEFT JOIN staff s ON s.amka=d.dept_manager
        LEFT JOIN room r ON r.dept_name=d.dept_name
        LEFT JOIN department_doctor dd ON dd.dept_name=d.dept_name
        GROUP BY d.dept_name
        ORDER BY d.dept_name
    """)
    return render_template("departments/list.html", rows=rows)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
