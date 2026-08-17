from flask import Blueprint, jsonify, request
from database import get_connection

ai_reports_bp = Blueprint("ai_reports", __name__)


# =========================================================
# GET STUDENT DATA FOR AI REPORT
# =========================================================

@ai_reports_bp.route("/ai-reports/student-data", methods=["GET"])
def get_student_report_data():

    student_id = request.args.get("student_id")
    month = request.args.get("month")  # YYYY-MM

    if not student_id:
        return jsonify({
            "success": False,
            "message": "student_id is required"
        }), 400

    if not month:
        return jsonify({
            "success": False,
            "message": "month is required in YYYY-MM format"
        }), 400

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # =====================================================
        # STUDENT INFORMATION
        # =====================================================

        cursor.execute(
            """
            SELECT
                s.student_id,
                u.full_name AS student_name,
                s.class,
                s.section,
                s.roll_no
            FROM students s
            JOIN users u
                ON s.user_id = u.user_id
            WHERE s.student_id = %s
            """,
            (student_id,)
        )

        student = cursor.fetchone()

        if not student:
            return jsonify({
                "success": False,
                "message": "Student not found"
            }), 404

        # =====================================================
        # MARKS
        # =====================================================

        cursor.execute(
            """
            SELECT
                subject,
                assessment_type,
                assessment_category,
                assessment_name,
                assessment_date,
                marks_obtained,
                total_marks,
                teacher_remarks
            FROM marks
            WHERE student_id = %s
            AND DATE_FORMAT(assessment_date, '%%Y-%%m') = %s
            ORDER BY assessment_date
            """,
            (student_id, month)
        )

        marks = cursor.fetchall()

        # =====================================================
        # ATTENDANCE
        # =====================================================

        cursor.execute(
            """
            SELECT
                attendance_date,
                status
            FROM attendance
            WHERE student_id = %s
            AND DATE_FORMAT(attendance_date, '%%Y-%%m') = %s
            ORDER BY attendance_date
            """,
            (student_id, month)
        )

        attendance_records = cursor.fetchall()

        # =====================================================
        # HOMEWORK
        # =====================================================

        cursor.execute(
            """
            SELECT
                hs.homework_id,
                hs.status,
                hs.submitted_at,
                h.subject,
                h.title,
                h.assigned_date,
                h.due_date
            FROM homework_submissions hs

            JOIN homework h
                ON hs.homework_id = h.homework_id

            WHERE hs.student_id = %s
            AND DATE_FORMAT(h.assigned_date, '%%Y-%%m') = %s

            ORDER BY h.assigned_date
            """,
            (student_id, month)
        )

        homework = cursor.fetchall()

        # =====================================================
        # ATTENDANCE PERCENTAGE
        # =====================================================

        total_attendance = len(attendance_records)

        present_days = sum(
            1
            for record in attendance_records
            if record["status"] == "Present"
        )

        attendance_percentage = 0

        if total_attendance > 0:
            attendance_percentage = round(
                (present_days / total_attendance) * 100,
                2
            )

        # =====================================================
        # AVERAGE MARKS
        # =====================================================

        total_marks_percentage = 0
        valid_marks = 0

        for mark in marks:

            if (
                mark["marks_obtained"] is not None
                and mark["total_marks"] is not None
                and float(mark["total_marks"]) > 0
            ):

                total_marks_percentage += (
                    float(mark["marks_obtained"])
                    / float(mark["total_marks"])
                ) * 100

                valid_marks += 1

        average_marks = 0

        if valid_marks > 0:
            average_marks = round(
                total_marks_percentage / valid_marks,
                2
            )

        # =====================================================
        # HOMEWORK COMPLETION
        # =====================================================

        total_homework = len(homework)

        completed_homework = sum(
            1
            for item in homework
            if item["status"] == "Completed"
        )

        homework_completion = 0

        if total_homework > 0:
            homework_completion = round(
                (completed_homework / total_homework) * 100,
                2
            )

        # =====================================================
        # RESPONSE
        # =====================================================

        return jsonify({
            "success": True,

            "student": student,

            "month": month,

            "summary": {
                "attendance_percentage": attendance_percentage,
                "average_marks": average_marks,
                "homework_completion": homework_completion
            },

            "marks": marks,

            "attendance": attendance_records,

            "homework": homework
        }), 200

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
            