from flask import Blueprint, request, jsonify
from database import get_connection

marks_bp = Blueprint("marks", __name__)


# =========================================================
# GET MARKS
# =========================================================
@marks_bp.route("/marks", methods=["GET"])
def get_marks():

    student_id = request.args.get("student_id")
    teacher_id = request.args.get("teacher_id")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
        SELECT
            m.mark_id,
            m.student_id,
            m.teacher_id,
            s.student_name,
            s.class,
            s.section,
            m.subject,
            m.exam_name,
            m.assessment_type,
            m.assessment_category,
            m.assessment_name,
            m.assessment_date,
            m.academic_year,
            m.marks_obtained,
            m.total_marks,
            m.teacher_remarks
        FROM marks m
        JOIN students s
            ON m.student_id = s.student_id
    """

    conditions = []
    values = []

    if student_id:
        conditions.append("m.student_id = %s")
        values.append(student_id)

    if teacher_id:
        conditions.append("m.teacher_id = %s")
        values.append(teacher_id)

    if conditions:
        query += " WHERE " + " AND ".join(conditions)

    query += " ORDER BY m.assessment_date DESC, m.mark_id DESC"

    cursor.execute(query, values)

    marks = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify(marks), 200


# =========================================================
# ADD MARKS
# =========================================================
@marks_bp.route("/marks", methods=["POST"])
def add_marks():

    data = request.get_json()

    student_id = data.get("student_id")
    teacher_id = data.get("teacher_id")
    subject = data.get("subject")

    assessment_type = data.get("assessment_type")
    assessment_category = data.get("assessment_category")
    assessment_name = data.get("assessment_name")
    assessment_date = data.get("assessment_date")
    academic_year = data.get("academic_year")

    marks_obtained = data.get("marks_obtained")
    total_marks = data.get("total_marks")

    teacher_remarks = data.get("teacher_remarks")

    # Keep exam_name for compatibility with existing table/data
    exam_name = assessment_name

    if not student_id:
        return jsonify({"error": "Student ID is required"}), 400

    if not teacher_id:
        return jsonify({"error": "Teacher ID is required"}), 400

    if not subject:
        return jsonify({"error": "Subject is required"}), 400

    if not assessment_type:
        return jsonify({"error": "Assessment type is required"}), 400

    if not assessment_category:
        return jsonify({"error": "Assessment category is required"}), 400

    if not assessment_name:
        return jsonify({"error": "Assessment name is required"}), 400

    if marks_obtained is None:
        return jsonify({"error": "Marks obtained is required"}), 400

    if total_marks is None:
        return jsonify({"error": "Total marks is required"}), 400

    try:
        marks_obtained = float(marks_obtained)
        total_marks = float(total_marks)
    except (TypeError, ValueError):
        return jsonify({"error": "Marks must be numbers"}), 400

    if total_marks <= 0:
        return jsonify({"error": "Total marks must be greater than 0"}), 400

    if marks_obtained < 0:
        return jsonify({"error": "Marks obtained cannot be negative"}), 400

    if marks_obtained > total_marks:
        return jsonify({
            "error": "Marks obtained cannot be greater than total marks"
        }), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    query = """
        INSERT INTO marks (
            student_id,
            teacher_id,
            subject,
            exam_name,
            assessment_type,
            assessment_category,
            assessment_name,
            assessment_date,
            academic_year,
            marks_obtained,
            total_marks,
            teacher_remarks
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    values = (
        student_id,
        teacher_id,
        subject,
        exam_name,
        assessment_type,
        assessment_category,
        assessment_name,
        assessment_date,
        academic_year,
        marks_obtained,
        total_marks,
        teacher_remarks
    )

    cursor.execute(query, values)

    conn.commit()

    mark_id = cursor.lastrowid

    cursor.close()
    conn.close()

    return jsonify({
        "message": "Marks added successfully",
        "mark_id": mark_id
    }), 201