from database import get_db_connection

def create_teacher(name, email, password, department_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO teachers (name, email, password, department_id) VALUES (%s, %s, %s, %s)",
        (name, email, password, department_id)
    )

    conn.commit()
    conn.close()


def get_teacher_by_email(email):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM teachers WHERE email=%s", (email,))
    teacher = cursor.fetchone()

    conn.close()
    return teacher