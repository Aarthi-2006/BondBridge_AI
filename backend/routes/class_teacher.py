from flask import Blueprint, request, jsonify
from database import get_connection

class_teacher = Blueprint("class_teacher", __name__)


# -------------------------------
# Get all teachers
# -------------------------------
@class_teacher.route("/teachers_list", methods=["GET"])
def teachers_list():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            teacher_id,
            employee_id
        FROM teachers
        ORDER BY employee_id
    """)

    teachers = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify(teachers)


# -------------------------------
# Assign Class Teacher
# -------------------------------
@class_teacher.route("/assign_class_teacher", methods=["POST"])
def assign_class_teacher():

    data = request.json

    teacher_id = data.get("teacher_id")
    class_name = data.get("class")
    section = data.get("section")

    conn = get_connection()
    cursor = conn.cursor()

    # Check whether class already has a class teacher
    cursor.execute("""
        SELECT assignment_id
        FROM class_teacher_assignment
        WHERE class=%s
        AND section=%s
    """, (class_name, section))

    exists = cursor.fetchone()

    if exists:
        cursor.close()
        conn.close()

        return jsonify({
            "success": False,
            "message": "Class teacher already assigned."
        })

    cursor.execute("""
        INSERT INTO class_teacher_assignment
        (teacher_id, class, section)
        VALUES (%s,%s,%s)
    """, (teacher_id, class_name, section))

    conn.commit()

    cursor.close()
    conn.close()

    return jsonify({
        "success": True,
        "message": "Class teacher assigned successfully."
    })


# -------------------------------
# View Assignments
# -------------------------------
@class_teacher.route("/class_teacher_assignments", methods=["GET"])
def class_teacher_assignments():

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            c.assignment_id,
            c.class,
            c.section,
            t.teacher_id,
            t.employee_id
        FROM class_teacher_assignment c
        JOIN teachers t
        ON c.teacher_id=t.teacher_id
        ORDER BY c.class,c.section
    """)

    data = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify(data)
    # -------------------------------
# Get Assigned Classes of Teacher
# -------------------------------

@class_teacher.route("/teacher_classes/<int:teacher_id>", methods=["GET"])
def teacher_classes(teacher_id):

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            class,
            section
        FROM class_teacher_assignment
        WHERE teacher_id = %s
        ORDER BY class, section
    """, (teacher_id,))

    data = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify({
        "success": True,
        "classes": data
    })