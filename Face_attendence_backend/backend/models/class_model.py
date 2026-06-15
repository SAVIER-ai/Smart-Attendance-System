from database import get_db_connection


def get_classes_by_department(department_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM classes WHERE department_id=%s",
        (department_id,)
    )

    data = cursor.fetchall()
    conn.close()
    return data
