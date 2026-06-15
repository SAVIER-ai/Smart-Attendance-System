from database import get_db_connection

from database import get_db_connection

def mark_attendance(student_id, subject_id, date, time, status):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        """
        SELECT attendance_id
        FROM attendance
        WHERE student_id=%s
        AND subject_id=%s
        AND date=%s
        """,
        (
            student_id,
            subject_id,
            date
        )
    )

    existing = cursor.fetchone()

    if existing:
        conn.close()
        return

    cursor.execute(
        """
        INSERT INTO attendance
        (
            student_id,
            subject_id,
            date,
            time,
            status
        )
        VALUES (%s,%s,%s,%s,%s)
        """,
        (
            student_id,
            subject_id,
            date,
            time,
            status
        )
    )

    conn.commit()
    conn.close()

def mark_remaining_absent(
    class_id,
    subject_id,
    date
):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        """
        SELECT student_id
        FROM students
        WHERE class_id=%s
        """,
        (class_id,)
    )

    students = cursor.fetchall()

    for student in students:

        cursor.execute(
            """
            SELECT attendance_id
            FROM attendance
            WHERE student_id=%s
            AND subject_id=%s
            AND date=%s
            """,
            (
                student["student_id"],
                subject_id,
                date
            )
        )

        existing = cursor.fetchone()

        if not existing:

            cursor.execute(
                """
                INSERT INTO attendance
                (
                    student_id,
                    subject_id,
                    date,
                    time,
                    status
                )
                VALUES
                (
                    %s,
                    %s,
                    %s,
                    NOW(),
                    'Absent'
                )
                """,
                (
                    student["student_id"],
                    subject_id,
                    date
                )
            )

    conn.commit()
    conn.close()