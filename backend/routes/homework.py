from flask import Blueprint, jsonify, request
from database import get_connection
from datetime import datetime


homework = Blueprint("homework", __name__)


# =====================================
# GET ALL HOMEWORK
# =====================================

@homework.route("/homework", methods=["GET"])
def get_homework():

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        teacher_id = request.args.get("teacher_id")
        class_name = request.args.get("class")
        section = request.args.get("section")
        subject = request.args.get("subject")

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
            status
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
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
            data.get("status", "Active")
        )

        cursor.execute(query, values)

        # ID of newly created homework
        homework_id = cursor.lastrowid

        # ---------------------------------
        # FIND STUDENTS IN CLASS + SECTION
        # ---------------------------------

        student_query = """
        SELECT student_id
        FROM students
        WHERE class=%s
        AND section=%s
        """

        cursor.execute(
            student_query,
            (
                data["class"],
                data["section"]
            )
        )

        students_list = cursor.fetchall()

        # ---------------------------------
        # CREATE PENDING SUBMISSIONS
        # ---------------------------------

        submission_query = """
        INSERT INTO homework_submissions
        (
            homework_id,
            student_id,
            status
        )
        VALUES (%s, %s, 'Pending')
        """

        for student in students_list:

            cursor.execute(
                submission_query,
                (
                    homework_id,
                    student[0]
                )
            )

        # ---------------------------------
        # COMMIT EVERYTHING
        # ---------------------------------

        conn.commit()

        return jsonify({
            "success": True,
            "message": "Homework added successfully",
            "homework_id": homework_id,
            "students_added": len(students_list)
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
# STUDENT MARKS HOMEWORK AS COMPLETED
# =====================================

@homework.route(
    "/homework/<int:homework_id>/submit",
    methods=["POST"]
)
def submit_homework(homework_id):

    conn = None
    cursor = None

    try:

        data = request.get_json()

        student_id = data.get("student_id")

        if not student_id:

            return jsonify({
                "success": False,
                "message": "student_id is required"
            }), 400

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # ---------------------------------
        # GET HOMEWORK
        # ---------------------------------

        cursor.execute(
            """
            SELECT
                homework_id,
                class,
                section,
                due_date
            FROM homework
            WHERE homework_id=%s
            """,
            (homework_id,)
        )

        homework_data = cursor.fetchone()

        if not homework_data:

            return jsonify({
                "success": False,
                "message": "Homework not found"
            }), 404

        # ---------------------------------
        # CHECK STUDENT
        # ---------------------------------

        cursor.execute(
            """
            SELECT
                student_id,
                class,
                section
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

        # ---------------------------------
        # CHECK CLASS + SECTION
        # ---------------------------------

        if (
            student["class"] != homework_data["class"]
            or student["section"] != homework_data["section"]
        ):

            return jsonify({
                "success": False,
                "message": "Student is not assigned to this homework"
            }), 403

        # ---------------------------------
        # CHECK SUBMISSION EXISTS
        # ---------------------------------

        cursor.execute(
            """
            SELECT
                submission_id,
                status
            FROM homework_submissions
            WHERE homework_id=%s
            AND student_id=%s
            """,
            (
                homework_id,
                student_id
            )
        )

        submission = cursor.fetchone()

        if not submission:

            return jsonify({
                "success": False,
                "message": "Homework submission record not found"
            }), 404

        # ---------------------------------
        # DETERMINE COMPLETED / LATE
        # ---------------------------------

        submitted_at = datetime.now()

        due_date = homework_data["due_date"]

        if submitted_at.date() <= due_date:

            status = "Completed"

        else:

            status = "Late"

        # ---------------------------------
        # UPDATE SUBMISSION
        # ---------------------------------

        cursor.execute(
            """
            UPDATE homework_submissions
            SET
                status=%s,
                submitted_at=%s
            WHERE homework_id=%s
            AND student_id=%s
            """,
            (
                status,
                submitted_at,
                homework_id,
                student_id
            )
        )

        conn.commit()

        return jsonify({
            "success": True,
            "message": "Homework submitted successfully",
            "status": status,
            "submitted_at": submitted_at
        })

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
# GET HOMEWORK SUBMISSIONS
# =====================================

@homework.route(
    "/homework/<int:homework_id>/submissions",
    methods=["GET"]
)
def get_homework_submissions(homework_id):

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # ---------------------------------
        # GET SUBMISSIONS
        # ---------------------------------

        query = """
        SELECT
            hs.submission_id,
            hs.homework_id,
            hs.student_id,
            u.full_name,
            s.roll_no,
            hs.status,
            hs.submitted_at,
            hs.teacher_remarks

        FROM homework_submissions hs

        JOIN students s
            ON hs.student_id = s.student_id

        JOIN users u
            ON s.user_id = u.user_id

        WHERE hs.homework_id=%s

        ORDER BY
            CAST(s.roll_no AS UNSIGNED)
        """

        cursor.execute(
            query,
            (homework_id,)
        )

        submissions = cursor.fetchall()

        # ---------------------------------
        # CALCULATE SUMMARY
        # ---------------------------------

        total = len(submissions)

        completed = sum(
            1 for item in submissions
            if item["status"] == "Completed"
        )

        pending = sum(
            1 for item in submissions
            if item["status"] == "Pending"
        )

        late = sum(
            1 for item in submissions
            if item["status"] == "Late"
        )

        completion_percentage = 0

        if total > 0:

            completion_percentage = round(
                (completed / total) * 100,
                2
            )

        return jsonify({
            "success": True,

            "summary": {
                "total": total,
                "completed": completed,
                "pending": pending,
                "late": late,
                "completion_percentage": completion_percentage
            },

            "submissions": submissions
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