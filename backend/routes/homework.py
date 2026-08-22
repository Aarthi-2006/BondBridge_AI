from flask import Blueprint, jsonify, request
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
            due_date,
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
# GET SUBMISSIONS
# =====================================

@homework.route("/homework", methods=["GET"])
def get_homework():

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        teacher_id = request.args.get("teacher_id")
        student_id = request.args.get("student_id")
        class_name = request.args.get("class")
        section = request.args.get("section")
        subject = request.args.get("subject")

        # =====================================
        # STUDENT HOMEWORK
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

                cursor.close()
                conn.close()

                return jsonify({
                    "success": False,
                    "message": "Student not found"
                }), 404

            # Only return homework for student's class + section
            query = """
            SELECT *
            FROM homework
            WHERE class=%s
            AND section=%s
            """

            params = [
                student["class"],
                student["section"]
            ]

            if subject:
                query += " AND subject=%s"
                params.append(subject)

            query += " ORDER BY created_at DESC"

        # =====================================
        # TEACHER HOMEWORK
        # =====================================

        else:

            query = """
            SELECT *
            FROM homework
            WHERE 1=1
            """

            params = []

            if teacher_id:
                query += " AND teacher_id=%s"
                params.append(teacher_id)

            if class_name:
                query += " AND class=%s"
                params.append(class_name)

            if section:
                query += " AND section=%s"
                params.append(section)

            if subject:
                query += " AND subject=%s"
                params.append(subject)

            query += " ORDER BY created_at DESC"

        cursor.execute(query, params)

        homework_list = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "homework": homework_list
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500