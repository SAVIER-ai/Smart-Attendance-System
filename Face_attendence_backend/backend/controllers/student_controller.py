from models.student_model import create_student
from services.face_service import encode_face_from_base64
from database import get_db_connection

def register_student(data):
    try:
        name = data.get("name")
        roll_no = data.get("roll_no")
        phone = data.get("phone")
        class_id = data.get("class_id")
        image = data.get("image")   # base64 image
        
        # Validate required fields
        if not all([name, roll_no, phone, class_id, image]):
            return {"error": "Missing required fields"}, 400

        # Convert face to encoding
        face_encoding = encode_face_from_base64(image)

        if face_encoding is None:
            return {"error": "Face not detected in the image"}, 400

        create_student(name, roll_no, phone, class_id, face_encoding)

        return {"message": "Student registered successfully"}, 201
    except Exception as e:
        return {"error": f"Registration failed: {str(e)}"}, 500
    

def get_all_students(admin_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
        SELECT
            students.student_id,
            students.name,
            students.roll_no,
            students.phone,
            classes.class_name,
            department.department_name

        FROM students

        JOIN classes
            ON students.class_id = classes.class_id

        JOIN department
            ON classes.department_id = department.department_id

        WHERE department.admin_id = %s
        """

        cursor.execute(query, (admin_id,))

        students = cursor.fetchall()

        conn.close()

        return {
            "status": "success",
            "data": students
        }

    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }
    
def get_students_by_class(class_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                student_id,
                name,
                roll_no
            FROM students
            WHERE class_id=%s
            """,
            (class_id,)
        )

        data = cursor.fetchall()

        conn.close()

        return {
            "status": "success",
            "data": data
        }

    except Exception as e:
        return {
            "error": str(e)
        }, 500   

def delete_student_controller(student_id):
    try:
        conn = get_db_connection()

        cursor = conn.cursor()

        # delete attendance first
        cursor.execute(
            "DELETE FROM attendance WHERE student_id=%s",
            (student_id,)
        )

        # delete student
        cursor.execute(
            "DELETE FROM students WHERE student_id=%s",
            (student_id,)
        )

        conn.commit()
        conn.close()

        return {
            "message": "Student deleted"
        }, 200

    except Exception as e:
        return {
            "error": str(e)
        }, 500     