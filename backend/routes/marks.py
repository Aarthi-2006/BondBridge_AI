from flask import Blueprint, request, jsonify
from database import get_connection

marks_bp = Blueprint("marks", __name__)
# =========================================================
# CHECK TEACHER CLASS/SECTION PERMISSION
# =========================================================

def teacher_has_class_permission(cursor, teacher_id, student_id):
    query = """
        SELECT 1
        FROM students s
        INNER JOIN class_teacher_assignment cta
            ON cta.class = s.class
            AND cta.section = s.section
        WHERE s.student_id = %s
          AND cta.teacher_id = %s
        LIMIT 1
    """

    cursor.execute(
        query,
        (student_id, teacher_id)
    )

    return cursor.fetchone() is not None

# =========================================================
# GET MARKS
# =========================================================
# =========================================================
# GET MARKS
# =========================================================

# =========================================================
# GET MARKS
# =========================================================

@marks_bp.route("/marks", methods=["GET"])
def get_marks():

    student_id = request.args.get("student_id")
    teacher_id = request.args.get("teacher_id")
    student_class = request.args.get("class")
    section = request.args.get("section")
    month = request.args.get("month")
    assessment_type = request.args.get("assessment_type")
    assessment_category = request.args.get("assessment_category")
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
        SELECT
            m.mark_id,
            s.student_id,
            m.teacher_id,

            u.full_name AS student_name,

            s.roll_no,
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
            m.teacher_remarks,
            m.activity_category,
            m.activity,
            m.achievement,
            m.level

        FROM students s

        JOIN users u
            ON s.user_id = u.user_id

        LEFT JOIN marks m
            ON s.student_id = m.student_id
    """

    conditions = []
    values = []

    # ==========================================
    # STUDENT FILTER
    # ==========================================

    if student_id:
        conditions.append("s.student_id = %s")
        values.append(student_id)

    # ==========================================
    # TEACHER FILTER
    # ==========================================

    if teacher_id:
        conditions.append("""
            EXISTS (
              SELECT 1
              FROM class_teacher_assignment cta
              WHERE cta.teacher_id = %s
                AND cta.class = s.class
                AND cta.section = s.section
            )
        """)
        values.append(teacher_id)
    # ==========================================
    # CLASS FILTER
    # ==========================================

    if student_class:
        conditions.append("s.class = %s")
        values.append(student_class)

    # ==========================================
    # SECTION FILTER
    # ==========================================

    if section:
        conditions.append("s.section = %s")
        values.append(section)
    # ==========================================
# ASSESSMENT TYPE FILTER
# ==========================================

    # ==========================================
# ASSESSMENT TYPE + MONTH FILTER
# ==========================================

    # ==========================================
# ASSESSMENT CATEGORY FILTER
# ==========================================

    if assessment_category:
        conditions.append(
            "m.assessment_category = %s"
        )
        values.append(assessment_category)


# ==========================================
# ASSESSMENT TYPE + MONTH FILTER
# ==========================================

    if assessment_type:
        conditions.append(
            "m.assessment_type = %s"
        )
        values.append(assessment_type)
        if assessment_type == "Monthly Test":

            if not month:
                cursor.close()
                conn.close()

                return jsonify({
                    "error": "Month is required for Monthly Test"
                }), 400

            conditions.append(
                "m.assessment_name = %s"
            )

            values.append(
                f"{month} Monthly Test"
            )
              
    # ==========================================
    # WHERE
    # ==========================================

    if conditions:
        query += " WHERE " + " AND ".join(conditions)

    # ==========================================
    # ORDER
    # ==========================================

    query += """
        ORDER BY
            CAST(s.roll_no AS UNSIGNED) ASC,
            m.assessment_date DESC,
            m.mark_id DESC
    """

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
    month = data.get("month")
    marks_obtained = data.get("marks_obtained")
    total_marks = data.get("total_marks")
    teacher_remarks = data.get("teacher_remarks")
    activity_category = data.get("activity_category")
    activity = data.get("activity")
    achievement = data.get("achievement")
    level = data.get("level")

    # Keep exam_name for compatibility with existing table/data
    # Monthly Test assessment name must include the selected month
    if assessment_category == "Academic" and assessment_type == "Monthly Test":
        if not month:
            return jsonify({
                "error": "Month is required for Monthly Test"
            }), 400

        assessment_name = f"{month} Monthly Test"
# Keep exam_name for compatibility
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
    if assessment_category == "Extracurricular":
        if not activity_category:
            return jsonify({"error": "Activity category is required"}), 400

        if activity_category == "Sports" and not activity:
            return jsonify({"error": "Sports activity is required"}), 400

        if not achievement:
            return jsonify({"error": "Achievement is required"}), 400

        if not level:
            return jsonify({"error": "Level is required"}), 400

    if not assessment_name:
        return jsonify({"error": "Assessment name is required"}), 400
    if assessment_category == "Academic" and assessment_type == "Monthly Test" and not month:
        return jsonify({
            "error": "Month is required for Monthly Test"
        }), 400
    if assessment_category == "Academic":

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
            return jsonify({
                "error": "Total marks must be greater than 0"
            }), 400

        if marks_obtained < 0:
            return jsonify({
                "error": "Marks obtained cannot be negative"
            }), 400

        if marks_obtained > total_marks:
            return jsonify({
                "error": "Marks obtained cannot be greater than total marks"
            }), 400

    else:
        marks_obtained = None
        total_marks = None
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

# =========================================================
# TEACHER CLASS/SECTION PERMISSION CHECK
# =========================================================

    if not teacher_has_class_permission(
      cursor,
      teacher_id,
      student_id
    ):
      cursor.close()
      conn.close()

      return jsonify({
         "error": "You are not assigned to this student's class and section."
      }), 403
    query = """
        INSERT INTO marks (
            student_id,
            teacher_id,
            subject,
            exam_name,
            assessment_type,
            assessment_category,
            assessment_name,
            month,
            assessment_date,
            academic_year,
            marks_obtained,
            total_marks,
            teacher_remarks,
            activity_category,
            activity,
            achievement,
            level
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    values = (
        student_id,
        teacher_id,
        subject,
        exam_name,
        assessment_type,
        assessment_category,
        assessment_name,
        month,
        assessment_date,
        academic_year,
        marks_obtained,
        total_marks,
        teacher_remarks,
        activity_category,
        activity,
        achievement,
        level
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