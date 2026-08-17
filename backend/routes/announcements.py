from flask import Blueprint, jsonify, request
from database import get_connection

announcements = Blueprint("announcements", __name__)


# =====================================================
# HELPER — GET TEACHER ASSIGNED CLASSES
# =====================================================

def teacher_has_class_permission(cursor, teacher_id, target_class, target_section):

    cursor.execute("""
        SELECT 1
        FROM class_teacher_assignment
        WHERE teacher_id=%s
        AND class=%s
        AND section=%s
        LIMIT 1
    """, (
        teacher_id,
        target_class,
        target_section
    ))

    return cursor.fetchone() is not None


# =====================================================
# GET ANNOUNCEMENTS
# =====================================================

@announcements.route("/announcements", methods=["GET"])
def get_announcements():

    try:

        role = request.args.get("role")
        user_id = request.args.get("user_id")
        teacher_id = request.args.get("teacher_id")

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # -------------------------------------------------
        # ADMIN → SEE EVERYTHING
        # -------------------------------------------------

        if role and role.lower() == "admin":

            cursor.execute("""
                SELECT *
                FROM announcements
                ORDER BY created_at DESC
            """)

        # -------------------------------------------------
        # TEACHER → GLOBAL + ASSIGNED CLASS ANNOUNCEMENTS
        # -------------------------------------------------

        elif role and role.lower() == "teacher":

            if not teacher_id:
                return jsonify({
                    "success": False,
                    "message": "teacher_id is required"
                }), 400

            cursor.execute("""
                SELECT *
                FROM announcements
                WHERE
                    created_by='Admin'
                    OR
                    (
                        teacher_id=%s
                        AND target_class IN (
                            SELECT class
                            FROM class_teacher_assignment
                            WHERE teacher_id=%s
                        )
                        AND target_section IN (
                            SELECT section
                            FROM class_teacher_assignment
                            WHERE teacher_id=%s
                        )
                    )
                ORDER BY created_at DESC
            """, (
                teacher_id,
                teacher_id,
                teacher_id
            ))

        # -------------------------------------------------
        # STUDENT
        # -------------------------------------------------

        elif role and role.lower() == "student":

            if not user_id:
                return jsonify({
                    "success": False,
                    "message": "user_id is required"
                }), 400

            cursor.execute("""
                SELECT
                    a.*
                FROM announcements a
                INNER JOIN students s
                    ON s.user_id=%s
                WHERE
                    a.created_by='Admin'
                    OR
                    (
                        a.target_class=s.class
                        AND a.target_section=s.section
                    )
                ORDER BY a.created_at DESC
            """, (user_id,))

        # -------------------------------------------------
        # PARENT
        # -------------------------------------------------

        elif role and role.lower() == "parent":

            if not user_id:
                return jsonify({
                    "success": False,
                    "message": "user_id is required"
                }), 400

            cursor.execute("""
                SELECT DISTINCT
                    a.*
                FROM announcements a
                INNER JOIN students s
                    ON s.parent_id=%s
                WHERE
                    a.created_by='Admin'
                    OR
                    (
                        a.target_class=s.class
                        AND a.target_section=s.section
                    )
                ORDER BY a.created_at DESC
            """, (user_id,))

        else:

            return jsonify({
                "success": False,
                "message": "Invalid role"
            }), 400

        data = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "total": len(data),
            "announcements": data
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500


# =====================================================
# GET SINGLE ANNOUNCEMENT
# =====================================================

@announcements.route("/announcements/<int:announcement_id>", methods=["GET"])
def get_single_announcement(announcement_id):

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT *
            FROM announcements
            WHERE announcement_id=%s
        """, (announcement_id,))

        announcement = cursor.fetchone()

        cursor.close()
        conn.close()

        if not announcement:

            return jsonify({
                "success": False,
                "message": "Announcement not found"
            }), 404

        return jsonify({
            "success": True,
            "announcement": announcement
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500


# =====================================================
# ADD ANNOUNCEMENT
# =====================================================

@announcements.route("/announcements", methods=["POST"])
def add_announcement():

    try:

        data = request.get_json()

        role = data.get("role")

        title = data.get("title")
        message = data.get("message")
        target_audience = data.get("target_audience")

        target_class = data.get("target_class")
        target_section = data.get("target_section")

        # -------------------------------------------------
        # BASIC VALIDATION
        # -------------------------------------------------

        if not title or not message:

            return jsonify({
                "success": False,
                "message": "Title and message are required"
            }), 400

        if not role:

            return jsonify({
                "success": False,
                "message": "Role is required"
            }), 400

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # -------------------------------------------------
        # ADMIN ANNOUNCEMENT
        # -------------------------------------------------

        if role.lower() == "admin":

            cursor.execute("""
                INSERT INTO announcements
                (
                    teacher_id,
                    title,
                    message,
                    target_audience,
                    target_class,
                    target_section,
                    created_by
                )
                VALUES
                (
                    NULL,
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    'Admin'
                )
            """, (
                title,
                message,
                target_audience,
                target_class,
                target_section
            ))

        # -------------------------------------------------
        # TEACHER ANNOUNCEMENT
        # -------------------------------------------------

        elif role.lower() == "teacher":

            teacher_id = data.get("teacher_id")

            if not teacher_id:

                cursor.close()
                conn.close()

                return jsonify({
                    "success": False,
                    "message": "teacher_id is required"
                }), 400

            if not target_class or not target_section:

                cursor.close()
                conn.close()

                return jsonify({
                    "success": False,
                    "message": "Class and section are required for teacher announcements"
                }), 400

            # Backend permission check
            allowed = teacher_has_class_permission(
                cursor,
                teacher_id,
                target_class,
                target_section
            )

            if not allowed:

                cursor.close()
                conn.close()

                return jsonify({
                    "success": False,
                    "message": "You are not assigned to this class and section"
                }), 403

            cursor.execute("""
                INSERT INTO announcements
                (
                    teacher_id,
                    title,
                    message,
                    target_audience,
                    target_class,
                    target_section,
                    created_by
                )
                VALUES
                (
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    'Teacher'
                )
            """, (
                teacher_id,
                title,
                message,
                target_audience,
                target_class,
                target_section
            ))

        else:

            cursor.close()
            conn.close()

            return jsonify({
                "success": False,
                "message": "Only Admin and Teacher can create announcements"
            }), 403

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Announcement added successfully"
        }), 201

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500


# =====================================================
# UPDATE ANNOUNCEMENT
# =====================================================

@announcements.route("/announcements/<int:announcement_id>", methods=["PUT"])
def update_announcement(announcement_id):

    try:

        data = request.get_json()

        role = data.get("role")
        teacher_id = data.get("teacher_id")

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT *
            FROM announcements
            WHERE announcement_id=%s
        """, (announcement_id,))

        existing = cursor.fetchone()

        if not existing:

            cursor.close()
            conn.close()

            return jsonify({
                "success": False,
                "message": "Announcement not found"
            }), 404

        # -------------------------------------------------
        # ADMIN CAN UPDATE ADMIN ANNOUNCEMENTS
        # -------------------------------------------------

        if role and role.lower() == "admin":

            if existing["created_by"] != "Admin":

                cursor.close()
                conn.close()

                return jsonify({
                    "success": False,
                    "message": "Admin can only update Admin announcements"
                }), 403

        # -------------------------------------------------
        # TEACHER CAN UPDATE OWN ANNOUNCEMENTS
        # -------------------------------------------------

        elif role and role.lower() == "teacher":

            if (
                existing["created_by"] != "Teacher"
                or str(existing["teacher_id"]) != str(teacher_id)
            ):

                cursor.close()
                conn.close()

                return jsonify({
                    "success": False,
                    "message": "You can only update your own announcements"
                }), 403

        else:

            cursor.close()
            conn.close()

            return jsonify({
                "success": False,
                "message": "Invalid role"
            }), 403

        title = data.get("title")
        message = data.get("message")
        target_audience = data.get("target_audience")
        target_class = data.get("target_class")
        target_section = data.get("target_section")

        # Teacher permission check when changing class/section
        if role.lower() == "teacher":

            if not target_class or not target_section:

                cursor.close()
                conn.close()

                return jsonify({
                    "success": False,
                    "message": "Class and section are required"
                }), 400

            allowed = teacher_has_class_permission(
                cursor,
                teacher_id,
                target_class,
                target_section
            )

            if not allowed:

                cursor.close()
                conn.close()

                return jsonify({
                    "success": False,
                    "message": "You are not assigned to this class and section"
                }), 403

        cursor.execute("""
            UPDATE announcements
            SET
                title=%s,
                message=%s,
                target_audience=%s,
                target_class=%s,
                target_section=%s
            WHERE announcement_id=%s
        """, (
            title,
            message,
            target_audience,
            target_class,
            target_section,
            announcement_id
        ))

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Announcement updated successfully"
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500


# =====================================================
# DELETE ANNOUNCEMENT
# =====================================================

@announcements.route("/announcements/<int:announcement_id>", methods=["DELETE"])
def delete_announcement(announcement_id):

    try:

        data = request.get_json() or {}

        role = data.get("role")
        teacher_id = data.get("teacher_id")

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT *
            FROM announcements
            WHERE announcement_id=%s
        """, (announcement_id,))

        existing = cursor.fetchone()

        if not existing:

            cursor.close()
            conn.close()

            return jsonify({
                "success": False,
                "message": "Announcement not found"
            }), 404

        # -------------------------------------------------
        # ADMIN
        # -------------------------------------------------

        if role and role.lower() == "admin":

            if existing["created_by"] != "Admin":

                cursor.close()
                conn.close()

                return jsonify({
                    "success": False,
                    "message": "Admin can only delete Admin announcements"
                }), 403

        # -------------------------------------------------
        # TEACHER
        # -------------------------------------------------

        elif role and role.lower() == "teacher":

            if (
                existing["created_by"] != "Teacher"
                or str(existing["teacher_id"]) != str(teacher_id)
            ):

                cursor.close()
                conn.close()

                return jsonify({
                    "success": False,
                    "message": "You can only delete your own announcements"
                }), 403

        else:

            cursor.close()
            conn.close()

            return jsonify({
                "success": False,
                "message": "Invalid role"
            }), 403

        cursor.execute("""
            DELETE FROM announcements
            WHERE announcement_id=%s
        """, (announcement_id,))

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": "Announcement deleted successfully"
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500