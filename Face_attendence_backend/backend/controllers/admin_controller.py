import random
import string
from flask import jsonify
from models.department_model import create_department
from models.class_model import get_classes_by_department
from database import get_db_connection
from models.department_model import get_all_departments

# Generate Department Code
def generate_code():
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
# Fetch Departments
def fetch_departments(admin_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM department WHERE admin_id=%s",
        (admin_id,)
    )

    data = cursor.fetchall()

    conn.close()

    return {"data": data}

# Delete Department
def delete_department_controller(dept_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # get classes
        cursor.execute(
            "SELECT class_id FROM classes WHERE department_id=%s",
            (dept_id,)
        )

        classes = cursor.fetchall()

        for cls in classes:
            class_id = cls[0]

            cursor.execute(
                "DELETE FROM subjects WHERE class_id=%s",
                (class_id,)
            )

            cursor.execute(
                "DELETE FROM students WHERE class_id=%s",
                (class_id,)
            )

        cursor.execute(
            "DELETE FROM classes WHERE department_id=%s",
            (dept_id,)
        )

        cursor.execute(
            "DELETE FROM teachers WHERE department_id=%s",
            (dept_id,)
        )

        cursor.execute(
            "DELETE FROM department WHERE department_id=%s",
            (dept_id,)
        )

        conn.commit()
        conn.close()

        return {
            "status": "success"
        }, 200

    except Exception as e:
        print("DELETE DEPARTMENT ERROR:", e)

        return {
            "error": str(e)
        }, 500
    
    
# Create Department
def add_department(data):
    try:
        print("DATA RECEIVED:", data)

        name = data.get("name")
        admin_id = data.get("admin_id")

        code = generate_code()

        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
        INSERT INTO department
        (department_name, department_code, admin_id)
        VALUES (%s, %s, %s)
        """

        values = (name, code, admin_id)

        

        cursor.execute(query, values)

        conn.commit()

        dept_id = cursor.lastrowid

        conn.close()

        return {
            "status": "success",
            "department_id": dept_id,
            "department_name": name,
            "department_code": code,
            "admin_id": admin_id
        }

    except Exception as e:
        print("DEPARTMENT ERROR:", e)

        return {
            "error": str(e)
        }, 500

# Get Classes by Department
def fetch_classes_controller(dept_id):
    try:
        data = get_classes_by_department(dept_id)
        return {"data": data}, 200
    except Exception as e:
        return {"error": str(e)}, 500

# Create Class
def create_class_controller(data):

    try:

        class_name = data.get(
            "class_name"
        )

        department_id = data.get(
            "department_id"
        )

        conn = get_db_connection()

        cursor = conn.cursor()

        cursor.execute(
            """
            INSERT INTO classes
            (
                class_name,
                department_id
            )

            VALUES (%s, %s)
            """,

            (
                class_name,
                department_id
            )
        )

        conn.commit()

        conn.close()

        return {
            "message":
                "Class created"
        }, 200

    except Exception as e:

        return {
            "error": str(e)
        }, 500
# Create Subject    
def create_subject_controller(data):

    try:

        subject_name = data.get(
            "subject_name"
        )

        class_id = data.get(
            "class_id"
        )

        conn = get_db_connection()

        cursor = conn.cursor()

        cursor.execute(
            """
            INSERT INTO subjects
            (
                subject_name,
                class_id
            )

            VALUES (%s, %s)
            """,

            (
                subject_name,
                class_id
            )
        )

        conn.commit()

        conn.close()

        return {
            "message":
                "Subject created"
        }, 200

    except Exception as e:

        return {
            "error": str(e)
        }, 500    
# get subjects by class
def get_subjects_by_class(class_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM subjects WHERE class_id=%s",
        (class_id,)
    )

    data = cursor.fetchall()
    conn.close()
    return data   
# Delete Class
def delete_class_controller(class_id):

    try:

        conn = get_db_connection()

        cursor = conn.cursor()

        # DELETE ATTENDANCE
        cursor.execute(
            """
            DELETE attendance
            FROM attendance

            JOIN students
            ON attendance.student_id =
               students.student_id

            WHERE students.class_id=%s
            """,
            (class_id,)
        )

        # DELETE SUBJECT ATTENDANCE
        cursor.execute(
            """
            DELETE attendance
            FROM attendance

            JOIN subjects
            ON attendance.subject_id =
               subjects.subject_id

            WHERE subjects.class_id=%s
            """,
            (class_id,)
        )

        # DELETE STUDENTS
        cursor.execute(
            """
            DELETE FROM students
            WHERE class_id=%s
            """,
            (class_id,)
        )

        # DELETE SUBJECTS
        cursor.execute(
            """
            DELETE FROM subjects
            WHERE class_id=%s
            """,
            (class_id,)
        )

        # DELETE CLASS
        cursor.execute(
            """
            DELETE FROM classes
            WHERE class_id=%s
            """,
            (class_id,)
        )

        conn.commit()

        conn.close()

        return {
            "message":
                "Class deleted"
        }, 200

    except Exception as e:

        return {
            "error": str(e)
        }, 500
# Delete Subject
def delete_subject_controller(subject_id):

    try:

        conn = get_db_connection()

        cursor = conn.cursor()

        # DELETE ATTENDANCE FIRST
        cursor.execute(
            """
            DELETE FROM attendance
            WHERE subject_id=%s
            """,
            (subject_id,)
        )

        # DELETE SUBJECT
        cursor.execute(
            """
            DELETE FROM subjects
            WHERE subject_id=%s
            """,
            (subject_id,)
        )

        conn.commit()

        conn.close()

        return {
            "message":
                "Subject deleted"
        }, 200

    except Exception as e:

        return {
            "error": str(e)
        }, 500
    
# get dashboard overview    
def get_dashboard_overview(admin_id):

    try:
        conn = get_db_connection()

        cursor = conn.cursor(dictionary=True)

        # TOTAL DEPARTMENTS
        cursor.execute(
            """
            SELECT COUNT(*) AS total_departments
            FROM department
            WHERE admin_id=%s
            """,
            (admin_id,)
        )

        departments = cursor.fetchone()["total_departments"]

        # TOTAL CLASSES
        cursor.execute(
            """
            SELECT COUNT(*) AS total_classes

            FROM classes

            JOIN department
                ON classes.department_id =
                   department.department_id

            WHERE department.admin_id=%s
            """,
            (admin_id,)
        )

        classes = cursor.fetchone()["total_classes"]

        # TOTAL SUBJECTS
        cursor.execute(
            """
            SELECT COUNT(*) AS total_subjects

            FROM subjects

            JOIN classes
                ON subjects.class_id =
                   classes.class_id

            JOIN department
                ON classes.department_id =
                   department.department_id

            WHERE department.admin_id=%s
            """,
            (admin_id,)
        )

        subjects = cursor.fetchone()["total_subjects"]

        # TOTAL STUDENTS
        cursor.execute(
            """
            SELECT COUNT(*) AS total_students

            FROM students

            JOIN classes
                ON students.class_id =
                   classes.class_id

            JOIN department
                ON classes.department_id =
                   department.department_id

            WHERE department.admin_id=%s
            """,
            (admin_id,)
        )

        students = cursor.fetchone()["total_students"]

        # LAST 3 STUDENTS
        cursor.execute(
            """
            SELECT
                students.name,
                students.roll_no,
                classes.class_name

            FROM students

            JOIN classes
                ON students.class_id =
                   classes.class_id

            JOIN department
                ON classes.department_id =
                   department.department_id

            WHERE department.admin_id=%s

            ORDER BY students.student_id DESC

            LIMIT 3
            """,
            (admin_id,)
        )

        recent_students = cursor.fetchall()

        conn.close()

        return {
            "total_departments": departments,
            "total_classes": classes,
            "total_subjects": subjects,
            "total_students": students,
            "recent_students": recent_students
        }, 200

    except Exception as e:
        return {
            "error": str(e)
        }, 500         