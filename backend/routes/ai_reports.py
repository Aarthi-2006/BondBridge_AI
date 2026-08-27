import json

from flask import Blueprint, jsonify, request
from database import get_connection
from services.ai_service import generate_ai_response

ai_reports_bp = Blueprint("ai_reports", __name__)


# =========================================================
# GET STUDENT DATA FOR AI REPORT
# =========================================================

@ai_reports_bp.route("/ai-reports/student-data", methods=["GET"])
def get_student_report_data():

    student_id = request.args.get("student_id")
    month = request.args.get("month")

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
                teacher_remarks,
                activity_category,
                activity,
                achievement,
                level
            FROM marks
            WHERE student_id = %s
            AND DATE_FORMAT(assessment_date, '%Y-%m') = %s
            ORDER BY assessment_date
            """,
            (student_id, month)
        )

        marks = cursor.fetchall()

        # =====================================================
        # EXTRACURRICULAR ACTIVITIES
        # =====================================================

        cursor.execute(
            """
            SELECT
                activity_category,
                activity,
                achievement,
                level,
                assessment_date,
                teacher_remarks
            FROM marks
            WHERE student_id = %s
            AND assessment_category = 'Extracurricular'
            AND DATE_FORMAT(assessment_date, '%Y-%m') = %s
            ORDER BY assessment_date
            """,
            (student_id, month)
        )

        extracurricular = cursor.fetchall()

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
            AND DATE_FORMAT(attendance_date, '%Y-%m') = %s
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
            AND DATE_FORMAT(h.assigned_date, '%Y-%m') = %s
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

            "homework": homework,

            "extracurricular": extracurricular

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


# =========================================================
# GENERATE AI REPORT USING OLLAMA
# =========================================================

@ai_reports_bp.route("/ai-reports/generate", methods=["POST"])
def generate_student_ai_report():

    data = request.get_json()

    if not data:
        return jsonify({
            "success": False,
            "message": "Request body is required"
        }), 400

    student_id = data.get("student_id")
    month = data.get("month")

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
# CHECK IF REPORT ALREADY EXISTS FOR THIS STUDENT/MONTH
# =====================================================

        cursor.execute(
            """
            SELECT
                report_id,
                student_id,
                report_month,
                attendance_percentage,
                average_marks,
                homework_completion,
                strengths,
                improvement_areas,
                ai_suggestions,
                generated_at,
                status,
                reviewed_by,
                reviewed_at
            FROM ai_reports
            WHERE student_id = %s
            AND report_month = %s
            ORDER BY report_id DESC
            LIMIT 1
            """,
            (student_id, month)
        )

        existing_report = cursor.fetchone()

        if existing_report:

            return jsonify({
                "success": False,
                "report_exists": True,
                "message": "An AI report already exists for this student and month.",
                "report_id": existing_report["report_id"],
                "status": existing_report["status"],
                "report": existing_report
            }), 409

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
                teacher_remarks,
                activity_category,
                activity,
                achievement,
                level
            FROM marks
            WHERE student_id = %s
            AND DATE_FORMAT(assessment_date, '%Y-%m') = %s
            ORDER BY assessment_date
            """,
            (student_id, month)
        )

        marks = cursor.fetchall()

        # =====================================================
        # EXTRACURRICULAR ACTIVITIES
        # =====================================================

        cursor.execute(
            """
            SELECT
                activity_category,
                activity,
                achievement,
                level,
                assessment_date,
                teacher_remarks
            FROM marks
            WHERE student_id = %s
            AND assessment_category = 'Extracurricular'
            AND DATE_FORMAT(assessment_date, '%Y-%m') = %s
            ORDER BY assessment_date
            """,
            (student_id, month)
        )

        extracurricular = cursor.fetchall()

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
            AND DATE_FORMAT(attendance_date, '%Y-%m') = %s
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
            AND DATE_FORMAT(h.assigned_date, '%Y-%m') = %s
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
        # BUILD AI PROMPT
        # =====================================================

        prompt = f"""
You are an AI student progress analysis assistant for a school.

Analyze the following student's monthly academic data.

Student Information:
Name: {student["student_name"]}
Class: {student["class"]}
Section: {student["section"]}
Roll Number: {student["roll_no"]}
Report Month: {month}

Monthly Summary:
Attendance Percentage: {attendance_percentage}%
Average Marks: {average_marks}%
Homework Completion: {homework_completion}%

Marks:
{marks}

Attendance Records:
{attendance_records}

Homework:
{homework}

Extracurricular Activities:
{extracurricular}

Generate a professional, positive, and easy-to-understand monthly student progress analysis.

Return ONLY valid JSON.

Do not use markdown.
Do not use ```json.
Do not add any text before or after the JSON.

The JSON must have exactly these three fields:

{{
  "strengths": "Student strengths based only on the provided data.",
  "improvement_areas": "Areas where the student needs improvement based only on the provided data.",
  "ai_suggestions": "Practical and positive suggestions for the teacher and parent based only on the provided data."
}}

Important:
- Do not invent marks, attendance, homework, achievements, or other facts.
- If there is insufficient data, clearly say so.
- Do not assume that zero data means the student performed poorly.
- Distinguish between "no data available" and an actual zero performance.
- Consider extracurricular participation, achievements and activity levels when identifying strengths.
- Do not treat lack of extracurricular data as poor performance.
- Do not invent extracurricular achievements.
- Keep the suggestions constructive and supportive.
"""

        # =====================================================
        # SEND PROMPT TO OLLAMA
        # =====================================================

        ai_response = generate_ai_response(prompt)

        if not ai_response:

            return jsonify({
                "success": False,
                "message": "Ollama returned an empty response"
            }), 500

        # =====================================================
        # CLEAN OLLAMA JSON RESPONSE
        # =====================================================

        clean_response = ai_response.strip()

        if clean_response.startswith("```json"):
            clean_response = clean_response[7:]

        elif clean_response.startswith("```"):
            clean_response = clean_response[3:]

        if clean_response.endswith("```"):
            clean_response = clean_response[:-3]

        clean_response = clean_response.strip()

        # =====================================================
        # PARSE AI JSON
        # =====================================================

        try:

            ai_data = json.loads(clean_response)

        except json.JSONDecodeError as e:

            return jsonify({
                "success": False,
                "message": "Ollama returned invalid JSON",
                "raw_response": ai_response,
                "error": str(e)
            }), 500

        # =====================================================
        # GET AI REPORT FIELDS
        # =====================================================

        strengths = ai_data.get(
            "strengths",
            ""
        ).strip()

        improvement_areas = ai_data.get(
            "improvement_areas",
            ""
        ).strip()

        ai_suggestions = ai_data.get(
            "ai_suggestions",
            ""
        ).strip()

        # =====================================================
        # SAVE AI REPORT
        # =====================================================

        cursor.execute(
            """
            INSERT INTO ai_reports (
                student_id,
                report_month,
                attendance_percentage,
                average_marks,
                homework_completion,
                strengths,
                improvement_areas,
                ai_suggestions,
                status
            )
            VALUES (
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                'Pending'
            )
            """,
            (
                student_id,
                month,
                attendance_percentage,
                average_marks,
                homework_completion,
                strengths,
                improvement_areas,
                ai_suggestions
            )
        )

        conn.commit()

        report_id = cursor.lastrowid

        # =====================================================
        # RESPONSE
        # =====================================================

        return jsonify({

            "success": True,

            "message":
                "AI report generated and saved successfully",

            "report_id": report_id,

            "student": student,

            "month": month,

            "summary": {
                "attendance_percentage": attendance_percentage,
                "average_marks": average_marks,
                "homework_completion": homework_completion
            },

            "ai_report": {
                "strengths": strengths,
                "improvement_areas": improvement_areas,
                "ai_suggestions": ai_suggestions
            },

            "status": "Pending"

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
# =========================================================
# GET VERIFIED AI REPORTS FOR STUDENT
# =========================================================

@ai_reports_bp.route("/ai-reports/student-verified-reports", methods=["GET"])
def get_student_verified_ai_reports():

    student_id = request.args.get("student_id")

    if not student_id:
        return jsonify({
            "success": False,
            "message": "student_id is required"
        }), 400

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # =====================================================
        # CHECK STUDENT
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
        # GET VERIFIED REPORTS ONLY
        # =====================================================

        cursor.execute(
            """
            SELECT
                report_id,
                student_id,
                report_month,
                attendance_percentage,
                average_marks,
                homework_completion,
                strengths,
                improvement_areas,
                ai_suggestions,
                generated_at,
                status,
                reviewed_by,
                reviewed_at
            FROM ai_reports
            WHERE student_id = %s
            AND status = 'Verified'
            ORDER BY report_month DESC, generated_at DESC
            """,
            (student_id,)
        )

        reports = cursor.fetchall()

        # =====================================================
        # RESPONSE
        # =====================================================

        return jsonify({

            "success": True,

            "student": student,

            "reports": reports,

            "count": len(reports)

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

# =========================================================
# GET SAVED AI REPORTS FOR A STUDENT
# =========================================================

@ai_reports_bp.route("/ai-reports/student-reports", methods=["GET"])
def get_student_ai_reports():

    student_id = request.args.get("student_id")

    if not student_id:
        return jsonify({
            "success": False,
            "message": "student_id is required"
        }), 400

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # =====================================================
        # CHECK STUDENT
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
        # GET SAVED REPORTS
        # =====================================================

        cursor.execute(
            """
            SELECT
                report_id,
                student_id,
                report_month,
                attendance_percentage,
                average_marks,
                homework_completion,
                strengths,
                improvement_areas,
                ai_suggestions,
                generated_at,
                status,
                reviewed_by,
                reviewed_at
            FROM ai_reports
            WHERE student_id = %s
            ORDER BY report_month DESC, generated_at DESC
            """,
            (student_id,)
        )

        reports = cursor.fetchall()

        # =====================================================
        # RESPONSE
        # =====================================================

        return jsonify({

            "success": True,

            "student": student,

            "reports": reports,

            "count": len(reports)

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


# =========================================================
# GET PENDING AI REPORTS FOR TEACHER
# =========================================================

@ai_reports_bp.route("/ai-reports/pending", methods=["GET"])
def get_pending_ai_reports():

    teacher_id = request.args.get("teacher_id")

    if not teacher_id:
        return jsonify({
            "success": False,
            "message": "teacher_id is required"
        }), 400

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # =====================================================
        # GET TEACHER'S ASSIGNED STUDENTS
        # =====================================================

        cursor.execute(
            """
            SELECT
                ar.report_id,
                ar.student_id,
                ar.report_month,
                ar.attendance_percentage,
                ar.average_marks,
                ar.homework_completion,
                ar.strengths,
                ar.improvement_areas,
                ar.ai_suggestions,
                ar.generated_at,
                ar.status,
                ar.reviewed_by,
                ar.reviewed_at,

                u.full_name AS student_name,
                s.class,
                s.section,
                s.roll_no

            FROM ai_reports ar

            JOIN students s
                ON ar.student_id = s.student_id

            JOIN users u
                ON s.user_id = u.user_id

            JOIN class_teacher_assignment cta
                ON cta.class = s.class
                AND cta.section = s.section

            WHERE cta.teacher_id = %s
            AND ar.status = 'Pending'

            ORDER BY ar.generated_at DESC
            """,
            (teacher_id,)
        )

        reports = cursor.fetchall()

        return jsonify({

            "success": True,

            "reports": reports,

            "count": len(reports)

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
# =========================================================
# GENERATE FAMILY CELEBRATION SUGGESTION
# =========================================================

def generate_celebration_suggestion(
    report,
    student_name,
    previous_report=None
):

    current_marks = (
        float(report["average_marks"])
        if report["average_marks"] is not None
        else None
    )

    current_attendance = (
        float(report["attendance_percentage"])
        if report["attendance_percentage"] is not None
        else None
    )

    current_homework = (
        float(report["homework_completion"])
        if report["homework_completion"] is not None
        else None
    )

    previous_marks = None
    previous_attendance = None
    previous_homework = None

    if previous_report:

        if previous_report["average_marks"] is not None:
            previous_marks = float(
                previous_report["average_marks"]
            )

        if previous_report["attendance_percentage"] is not None:
            previous_attendance = float(
                previous_report["attendance_percentage"]
            )

        if previous_report["homework_completion"] is not None:
            previous_homework = float(
                previous_report["homework_completion"]
            )

    # =====================================================
    # CALCULATE CHANGES
    # =====================================================

    changes = []

    if current_marks is not None and previous_marks is not None:
        changes.append(
            current_marks - previous_marks
        )

    if current_attendance is not None and previous_attendance is not None:
        changes.append(
            current_attendance - previous_attendance
        )

    if current_homework is not None and previous_homework is not None:
        changes.append(
            current_homework - previous_homework
        )

    positive_changes = [
        change for change in changes
        if change > 0
    ]

    if positive_changes:
        overall_change = max(positive_changes)
    else:
        overall_change = 0

    # =====================================================
    # CELEBRATION LEVEL
    # =====================================================

    if overall_change >= 15:
        celebration_level = "Huge Improvement"

    elif overall_change >= 5:
        celebration_level = "Good Improvement"

    elif overall_change > 0:
        celebration_level = "Small Improvement"

    else:
        celebration_level = "Encouragement"

    # =====================================================
    # BUILD FAMILY-FOCUSED PROMPT
    # =====================================================

    prompt = f"""
You are a family engagement assistant for a school.

Your ONLY task is to create ONE family celebration or
quality-time activity for a parent and child.

This is NOT a student progress suggestion.
Do NOT give academic advice.
Do NOT repeat teacher recommendations.

Student Name:
{student_name}

Report Month:
{report["report_month"]}

Current Average Marks:
{current_marks if current_marks is not None else "No data available"}%

Current Attendance:
{current_attendance if current_attendance is not None else "No data available"}%

Current Homework Completion:
{current_homework if current_homework is not None else "No data available"}%

Previous Average Marks:
{previous_marks if previous_marks is not None else "No previous report available"}%

Previous Attendance:
{previous_attendance if previous_attendance is not None else "No previous report available"}%

Previous Homework Completion:
{previous_homework if previous_homework is not None else "No previous report available"}%

Overall Positive Change:
{round(overall_change, 2)} percentage points

Celebration Level:
{celebration_level}

Student Strengths:
{report["strengths"]}

Improvement Areas:
{report["improvement_areas"]}

=========================================================
FAMILY CELEBRATION RULES
=========================================================

1. Return ONE family-oriented activity only.

2. The activity must involve the parent/family and child
   spending positive quality time together.

3. Do NOT provide academic advice.

4. Do NOT repeat or rewrite the AI Suggestions.

5. Do NOT mention "AI Suggestions".

6. Do NOT tell the parent to study, practice, revise,
   complete homework, improve marks, or attend school.

7. Do NOT invent achievements.

8. The celebration must be affordable and practical.

9. Examples include:
   - family movie night
   - favorite home-cooked meal
   - board game together
   - short family outing
   - cooking together
   - playing the child's favorite game
   - reading together
   - outdoor walk or activity
   - small treat
   - family conversation
   - hobby activity together

10. If there is a large improvement, make the celebration
    feel more special.

11. If there is a small improvement, suggest a simple
    celebration.

12. If there is no measurable improvement, still provide
    a small encouragement activity.

13. If there is no previous report, do not claim improvement.
    Simply suggest a positive family activity based on the
    student's available strengths or participation.

14. The result must sound like a recommendation directly
    to the parent.

15. Keep it concise: one or two sentences.

16. Return ONLY the celebration text.

17. Do not use JSON.

18. Do not use markdown.

19. Do not add a heading.

20. Do not include academic recommendations.
"""

    celebration_text = generate_ai_response(prompt)

    if not celebration_text:
        return None

    return celebration_text.strip()

# =========================================================
# APPROVE / VERIFY AI REPORT
# AND AUTOMATICALLY GENERATE CELEBRATION
# =========================================================

@ai_reports_bp.route(
    "/ai-reports/<int:report_id>/approve",
    methods=["PUT"]
)
def approve_ai_report(report_id):

    data = request.get_json()

    if not data:
        return jsonify({
            "success": False,
            "message": "Request body is required"
        }), 400

    teacher_id = data.get("teacher_id")

    if not teacher_id:
        return jsonify({
            "success": False,
            "message": "teacher_id is required"
        }), 400

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # =====================================================
        # CHECK REPORT AND TEACHER AUTHORIZATION
        # =====================================================

        cursor.execute(
            """
            SELECT
                ar.report_id,
                ar.student_id,
                ar.report_month,
                ar.attendance_percentage,
                ar.average_marks,
                ar.homework_completion,
                ar.strengths,
                ar.improvement_areas,
                ar.ai_suggestions,
                ar.status,

                u.full_name AS student_name,

                s.class,
                s.section

            FROM ai_reports ar

            JOIN students s
                ON ar.student_id = s.student_id

            JOIN users u
                ON s.user_id = u.user_id

            JOIN class_teacher_assignment cta
                ON cta.class = s.class
                AND cta.section = s.section

            WHERE ar.report_id = %s
            AND cta.teacher_id = %s
            """,
            (report_id, teacher_id)
        )

        report = cursor.fetchone()

        if not report:

            return jsonify({
                "success": False,
                "message":
                    "Report not found or teacher is not authorized"
            }), 404

        # =====================================================
        # CHECK REPORT STATUS
        # =====================================================

        if report["status"] != "Pending":

            return jsonify({
                "success": False,
                "message":
                    "Only pending reports can be approved"
            }), 400

        # =====================================================
        # VERIFY REPORT
        # =====================================================

        cursor.execute(
            """
            UPDATE ai_reports
            SET
                status = 'Verified',
                reviewed_by = %s,
                reviewed_at = NOW()
            WHERE report_id = %s
            """,
            (teacher_id, report_id)
        )

        # =====================================================
# GET PREVIOUS VERIFIED REPORT
# =====================================================

        cursor.execute(
            """
            SELECT
                report_id,
                report_month,
                attendance_percentage,
                average_marks,
                homework_completion
            FROM ai_reports
            WHERE student_id = %s
            AND status = 'Verified'
            AND report_month < %s
            ORDER BY report_month DESC
            LIMIT 1
            """,
            (
                report["student_id"],
                report["report_month"]
            )
        )

        previous_report = cursor.fetchone()


# =====================================================
# GENERATE CELEBRATION
# =====================================================

        celebration_text = generate_celebration_suggestion(
            report,
            report["student_name"],
            previous_report
        )
        # =====================================================
# FALLBACK CELEBRATION
# =====================================================

        if not celebration_text:
            celebration_text = (
                f"Celebrate {report['student_name']}'s journey this month "
                "with a small family quality-time activity. Spend some "
                "time together doing something your child enjoys and "
                "encourage them to keep learning and making progress."
            )
        # =====================================================
        # CHECK WHETHER CELEBRATION ALREADY EXISTS
        # =====================================================

        cursor.execute(
            """
            SELECT
                celebration_id
            FROM ai_celebrations
            WHERE report_id = %s
            """,
            (report_id,)
        )

        existing_celebration = cursor.fetchone()

        # =====================================================
        # SAVE CELEBRATION
        # =====================================================

        if not existing_celebration:

            cursor.execute(
                """
                INSERT INTO ai_celebrations (
                    report_id,
                    student_id,
                    celebration_text
                )
                VALUES (
                    %s,
                    %s,
                    %s
                )
                """,
                (
                    report_id,
                    report["student_id"],
                    celebration_text
                )
            )

            celebration_id = cursor.lastrowid

        else:

            celebration_id = existing_celebration[
                "celebration_id"
            ]

        # =====================================================
        # COMMIT EVERYTHING
        # =====================================================

        conn.commit()

        # =====================================================
        # RESPONSE
        # =====================================================

        return jsonify({

            "success": True,

            "message":
                "AI report verified and celebration generated successfully",

            "report_id":
                report_id,

            "status":
                "Verified",

            "celebration_id":
                celebration_id,

            "celebration_text":
                celebration_text

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
# =========================================================
# GET VERIFIED AI REPORTS FOR PARENT'S CHILD
# =========================================================

@ai_reports_bp.route("/ai-reports/parent-reports", methods=["GET"])
def get_parent_ai_reports():

    parent_id = request.args.get("parent_id")

    if not parent_id:
        return jsonify({
            "success": False,
            "message": "parent_id is required"
        }), 400

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # =====================================================
        # GET PARENT'S CHILD
        # =====================================================

        cursor.execute(
            """
            SELECT
                p.parent_id,
                s.student_id,
                u.full_name AS student_name,
                s.class,
                s.section,
                s.roll_no
            FROM parents p

            INNER JOIN students s
                ON p.student_id = s.student_id

            INNER JOIN users u
                ON s.user_id = u.user_id

            WHERE p.parent_id = %s
            """,
            (parent_id,)
        )

        child = cursor.fetchone()

        if not child:

            return jsonify({
                "success": False,
                "message": "Child not found for this parent"
            }), 404

        # =====================================================
        # GET VERIFIED REPORTS ONLY
        # =====================================================

        cursor.execute(
            """
            SELECT
                ar.report_id,
                ar.student_id,
                ar.report_month,
                ar.attendance_percentage,
                ar.average_marks,
                ar.homework_completion,
                ar.strengths,
                ar.improvement_areas,
                ar.ai_suggestions,
                ar.generated_at,
                ar.status,
                ar.reviewed_by,
                ar.reviewed_at,
                c.celebration_id,
                c.celebration_text

            FROM ai_reports ar
            LEFT JOIN ai_celebrations c
                ON ar.report_id = c.report_id

            WHERE ar.student_id = %s
            AND ar.status = 'Verified'

            ORDER BY
                report_month DESC,
                generated_at DESC
            """,
            (child["student_id"],)
        )

        reports = cursor.fetchall()

        # =====================================================
        # RESPONSE
        # =====================================================

        return jsonify({

            "success": True,

            "child": child,

            "reports": reports,

            "count": len(reports)

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
# =========================================================
# STUDENT ASK AI
# =========================================================

@ai_reports_bp.route("/ask", methods=["POST"])
def ask_ai():

    try:

        data = request.get_json()

        if not data:
            return jsonify({
                "success": False,
                "message": "No request data received"
            }), 400

        question = data.get("question", "").strip()

        if not question:
            return jsonify({
                "success": False,
                "message": "Question is required"
            }), 400

        prompt = f"""
You are an academic AI assistant for students.

Answer the student's question clearly and accurately.

Student question:
{question}

Give a simple educational explanation suitable for a student.
"""

        answer = generate_ai_response(prompt)

        return jsonify({
            "success": True,
            "answer": answer
        }), 200

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500
# =========================================================
# GET FAMILY CELEBRATIONS FOR PARENT
# =========================================================

@ai_reports_bp.route("/ai-reports/parent-celebrations", methods=["GET"])
def get_parent_celebrations():

    parent_id = request.args.get("parent_id")

    if not parent_id:
        return jsonify({
            "success": False,
            "message": "parent_id is required"
        }), 400

    conn = None
    cursor = None

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # =====================================================
        # GET PARENT'S CHILD
        # =====================================================

        cursor.execute(
            """
            SELECT
                p.parent_id,
                s.student_id,
                u.full_name AS student_name
            FROM parents p

            INNER JOIN students s
                ON p.student_id = s.student_id

            INNER JOIN users u
                ON s.user_id = u.user_id

            WHERE p.parent_id = %s
            """,
            (parent_id,)
        )

        child = cursor.fetchone()

        if not child:

            return jsonify({
                "success": False,
                "message": "Child not found for this parent"
            }), 404

        # =====================================================
        # GET FAMILY CELEBRATIONS
        # =====================================================

        cursor.execute(
            """
            SELECT
                c.celebration_id,
                c.report_id,
                c.student_id,
                c.celebration_text,
                ar.report_month,
                ar.generated_at

            FROM ai_celebrations c

            INNER JOIN ai_reports ar
                ON c.report_id = ar.report_id

            WHERE c.student_id = %s
            AND ar.status = 'Verified'

            ORDER BY
                ar.report_month DESC,
                c.celebration_id DESC
            """,
            (child["student_id"],)
        )

        celebrations = cursor.fetchall()

        # =====================================================
        # RESPONSE
        # =====================================================

        return jsonify({

            "success": True,

            "child": child,

            "celebrations": celebrations,

            "count": len(celebrations)

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