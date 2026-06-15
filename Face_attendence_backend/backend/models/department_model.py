from database import get_db_connection

def create_department(name, code, admin_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO department (department_name, department_code, admin_id) VALUES (%s, %s, %s)",
        (name, code, admin_id)
    )

    conn.commit()
    conn.close()


def get_department_by_code(code):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM department WHERE department_code=%s", (code,))
    dept = cursor.fetchone()

    conn.close()
    return dept

def get_all_departments():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM department")
    data = cursor.fetchall()

    conn.close()
    return data