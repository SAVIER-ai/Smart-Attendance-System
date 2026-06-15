from database import get_db_connection

def create_student(name, roll_no, phone, class_id, face_encoding):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO students (name, roll_no, phone, class_id, face_encoding) VALUES (%s, %s, %s, %s, %s)",
        (name, roll_no, phone, class_id, face_encoding)
    )

    conn.commit()
    conn.close()


def get_students_by_class(class_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT student_id, name, face_encoding FROM students WHERE class_id = %s",
        (class_id,)
    )

    students = cursor.fetchall()

    conn.close()
    if not students:
        return []
    return students    