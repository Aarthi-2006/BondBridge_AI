from flask import Blueprint, jsonify, request, session
from database import get_connection
from datetime import datetime


homework = Blueprint("homework", __name__)



# =====================================
# ADD HOMEWORK
# =====================================

@homework.route("/homework", methods=["POST"])
def add_homework():

    conn = None
    cursor = None

    try:

        data = request.get_json()

        conn = get_connection()
        cursor = conn.cursor()

        # ---------------------------------
        # INSERT HOMEWORK
        # ---------------------------------

        query = """
        INSERT INTO homework
        (
            teacher_id,
            class,
            section,
            subject,
            title,
            description,
            assigned_date,
            due_date
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """

        values = (
            data["teacher_id"],
            data["class"],
            data["section"],
            data["subject"],
            data["title"],
            data["description"],
            data["assigned_date"],
            data["due_date"],
        )

        cursor.execute(query, values)

        # ID of newly created homework
        homework_id = cursor.lastrowid

        
        # ---------------------------------
        # COMMIT EVERYTHING
        # ---------------------------------

        conn.commit()

        return jsonify({
            "success": True,
            "message": "Homework added successfully",
            "homework_id": homework_id,
        }), 201

    except Exception as e:

        if conn:
            conn.rollback()

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()
# =====================================
# GET HOMEWORK
# =====================================

@homework.route("/homework", methods=["GET"])
def get_homework():

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        teacher_id = request.args.get("teacher_id")
        student_id = request.args.get("student_id")
        class_name = request.args.get("class")
        section = request.args.get("section")
        subject = request.args.get("subject")

        # =====================================
        # STUDENT / PARENT HOMEWORK
        # =====================================

        if student_id:

            # Get student's class and section
            cursor.execute(
                """
                SELECT class, section
                FROM students
                WHERE student_id=%s
                """,
                (student_id,)
            )

            student = cursor.fetchone()

            if not student:

                return jsonify({
                    "success": False,
                    "message": "Student not found"
                }), 404

            class_name = student["class"]
            section = student["section"]

        # =====================================
        # HOMEWORK FILTER
        # =====================================

        if student_id:

            query = """
            SELECT
                h.*,
                COALESCE(hs.status, 'Not Completed') AS completion_status,
                hs.submitted_at
            FROM homework h
            LEFT JOIN homework_submissions hs
                ON h.homework_id = hs.homework_id
                AND hs.student_id = %s
            WHERE 1=1
            """

            params = [student_id]

        else:

            query = """
            SELECT
                h.*,
                (
                    SELECT COUNT(*)
                    FROM students s
                    WHERE s.class = h.class
                    AND s.section = h.section
                ) AS total_students,
                (
                    SELECT COUNT(*)
                    FROM homework_submissions hs
                    WHERE hs.homework_id = h.homework_id
                    AND hs.status = 'Completed'
                ) AS completed_students
            FROM homework h
            WHERE 1=1
            """

            params = []

        # Class filter
        if class_name:
            query += " AND class=%s"
            params.append(class_name)

        # Section filter
        if section:
            query += " AND section=%s"
            params.append(section)

        # Teacher filter
        if teacher_id:
            query += " AND teacher_id=%s"
            params.append(teacher_id)

        # Subject filter
        if subject:
            query += " AND subject=%s"
            params.append(subject)

        query += " ORDER BY created_at DESC"

        cursor.execute(query, params)

        homework_list = cursor.fetchall()

        return jsonify({
            "success": True,
            "homework": homework_list
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()
# =====================================
# MARK HOMEWORK AS COMPLETED
# =====================================

@homework.route("/homework/<int:homework_id>/complete", methods=["POST"])
def complete_homework(homework_id):

    conn = None
    cursor = None

    try:

        # =====================================
        # VERIFY STUDENT
        # =====================================

        data = request.get_json() or {}

        role = data.get("role")
        student_id = data.get("student_id")

        if not student_id:

            return jsonify({
                "success": False,
                "message": "Student information not found"
            }), 403

        if not role or role.lower() != "student":

            return jsonify({
                "success": False,
                "message": "Only students can complete homework"
            }), 403

        # =====================================
        # DATABASE CONNECTION
        # =====================================

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # =====================================
        # VERIFY HOMEWORK EXISTS
        # =====================================

        cursor.execute(
            """
            SELECT homework_id
            FROM homework
            WHERE homework_id=%s
            """,
            (homework_id,)
        )

        homework_record = cursor.fetchone()

        if not homework_record:

            return jsonify({
                "success": False,
                "message": "Homework not found"
            }), 404

        # =====================================
        # CHECK EXISTING SUBMISSION
        # =====================================

        cursor.execute(
            """
            SELECT submission_id, status
            FROM homework_submissions
            WHERE homework_id=%s
            AND student_id=%s
            """,
            (homework_id, student_id)
        )

        submission = cursor.fetchone()

        # =====================================
        # ALREADY COMPLETED
        # =====================================

        if submission and submission["status"] == "Completed":

            return jsonify({
                "success": True,
                "message": "Homework already completed"
            }), 200

        # =====================================
        # CREATE OR UPDATE COMPLETION
        # =====================================

        if submission:

            cursor.execute(
                """
                UPDATE homework_submissions
                SET status='Completed',
                    submitted_at=NOW()
                WHERE submission_id=%s
                """,
                (submission["submission_id"],)
            )

        else:

            cursor.execute(
                """
                INSERT INTO homework_submissions
                (
                    homework_id,
                    student_id,
                    status,
                    submitted_at
                )
                VALUES (%s, %s, 'Completed', NOW())
                """,
                (homework_id, student_id)
            )

        # =====================================
        # COMMIT
        # =====================================

        conn.commit()

        return jsonify({
            "success": True,
            "message": "Homework marked as completed"
        }), 200

    except Exception as e:

        if conn:
            conn.rollback()

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if conn:
            conn.close()