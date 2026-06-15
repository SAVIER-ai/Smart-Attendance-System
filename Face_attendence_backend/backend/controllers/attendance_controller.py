from models.student_model import get_students_by_class
from models.attendance_model import (
    mark_attendance,
    mark_remaining_absent
)
from services.face_service import save_image, verify_faces
from datetime import datetime
import os
from database import get_db_connection

def mark_attendance_controller(data):
    try:
        class_id = data.get("class_id")
        subject_id = data.get("subject_id")
        image = data.get("image")
        
        # Validate required fields
        if not all([class_id, subject_id, image]):
            return {"error": "Missing required fields"}, 400

        # Save captured image
        captured_path = save_image(image)

        students = get_students_by_class(class_id)

        for student in students:
            matched = verify_faces(student["face_encoding"], captured_path)

            if matched:
                now = datetime.now()

                mark_attendance(
                    student["student_id"],
                    subject_id,
                    now.date(),
                    now.time(),
                    "Present"
                )

                # Remove temp file
                if os.path.exists(captured_path):
                    os.remove(captured_path)

                return {
                    "success": True,
                    "message": "Attendance marked successfully",
                    "student_name": student["name"]
                }, 200

        # Remove temp file
        if os.path.exists(captured_path):
            os.remove(captured_path)

        return {
                "success": False,
                "message": "Face not recognized"
            }, 200
        
    except Exception as e:
        return {"error": f"Attendance marking failed: {str(e)}"}, 500


def manual_attendance_controller(data):
    try:
        student_id = data.get("student_id")
        subject_id = data.get("subject_id")
        status = data.get("status")

        if not all([student_id, subject_id, status]):
            return {"error": "Missing fields"}, 400

        now = datetime.now()
        mark_attendance(
            student_id,
            subject_id,
            now.date(),
            now.time(),
            status   # 👈 ADD THIS PARAM
        )

        return {"message": "Attendance marked"}, 200

    except Exception as e:
        return {"error": str(e)}, 500
    

def get_class_attendance(
    class_id=None,
    subject_id=None,
    roll_no=None,
    filter_type=None
):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
    SELECT
        students.student_id,
        students.name,
        students.roll_no,
        classes.class_name,
        attendance.date,
        attendance.status,
        subjects.subject_name

    FROM attendance

    JOIN students
        ON attendance.student_id = students.student_id

    JOIN classes
        ON students.class_id = classes.class_id
        
    JOIN subjects
    ON attendance.subject_id = subjects.subject_id

    WHERE 1=1
    """

    values = []

    if class_id:
        query += " AND classes.class_id = %s"
        values.append(class_id)

    if subject_id:
        query += " AND attendance.subject_id = %s"
        values.append(subject_id)

    if roll_no:
        query += " AND students.roll_no = %s"
        values.append(roll_no)

    if filter_type == "today":
        query += " AND attendance.date = CURDATE()"

    elif filter_type == "weekly":
        query += """
        AND attendance.date >=
        DATE_SUB(CURDATE(), INTERVAL 7 DAY)
        """

    elif filter_type == "monthly":
        query += """
        AND attendance.date >=
        DATE_SUB(CURDATE(), INTERVAL 30 DAY)
        """

    query += " ORDER BY attendance.date DESC"

    cursor.execute(query, tuple(values))

    data = cursor.fetchall()

    conn.close()

    return data

def stop_attendance_controller(data):

    try:

        class_id = data.get("class_id")
        subject_id = data.get("subject_id")

        if not class_id or not subject_id:

            return {
                "error": "Missing fields"
            }, 400

        today = datetime.now().date()

        mark_remaining_absent(
            class_id,
            subject_id,
            today
        )

        return {
            "success": True,
            "message": "Attendance completed"
        }, 200

    except Exception as e:

        return {
            "error": str(e)
        }, 500