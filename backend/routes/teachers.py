from flask import Blueprint, request, jsonify
from database import get_connection


teachers = Blueprint(
    "teachers",
    __name__
)


# ==========================
# GET ALL TEACHERS
# ==========================

# ==========================
# GET ALL TEACHERS
# ==========================

@teachers.route("/teachers", methods=["GET"])
def get_teachers():

    try:

        connection = get_connection()

        cursor = connection.cursor(dictionary=True)


        subject = request.args.get("subject")


        query = """
        SELECT
            t.teacher_id,
            u.full_name,
            u.email,
            t.employee_id,
            t.subject,
            t.qualification,
            t.experience,
            t.phone_number,
            t.gender,
            t.date_of_birth,
            t.joining_date

        FROM teachers t

        JOIN users u
        ON t.user_id = u.user_id
        """


        values = []


        if subject:

            query += " WHERE t.subject = %s"

            values.append(subject)


        cursor.execute(query, values)

        teachers = cursor.fetchall()


        cursor.close()
        connection.close()


        return jsonify(teachers), 200


    except Exception as e:

        return jsonify({

            "error": str(e)

        }), 500


# ==========================
# GET SINGLE TEACHER PROFILE
# ==========================

@teachers.route("/teachers/<int:id>", methods=["GET"])
def get_teacher_profile(id):

    try:

        connection = get_connection()

        cursor = connection.cursor(dictionary=True)

        query = """
        SELECT
            t.teacher_id,
            u.full_name,
            u.email,
            t.employee_id,
            t.subject,
            t.qualification,
            t.experience,
            t.phone_number,
            t.gender,
            t.date_of_birth,
            t.joining_date

        FROM teachers t

        JOIN users u
        ON t.user_id = u.user_id

        WHERE t.teacher_id = %s
        """

        cursor.execute(query, (id,))

        teacher = cursor.fetchone()

        cursor.close()
        connection.close()

        if teacher is None:
            return jsonify({
                "success": False,
                "message": "Teacher not found"
            }), 404

        return jsonify({
            "success": True,
            "teacher": teacher
        }), 200

    except Exception as e:

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500
        # ==========================
# ADD TEACHER
# ==========================

@teachers.route("/teachers", methods=["POST"])
def add_teacher():

    try:

        data = request.json


        connection = get_connection()

        cursor = connection.cursor()



        # Insert into users table

        user_query = """
        INSERT INTO users
        (
            full_name,
            email,
            password,
            role
        )

        VALUES
        (
            %s,
            %s,
            %s,
            %s
        )
        """


        cursor.execute(
            user_query,
            (
                data["full_name"],
                data["email"],
                data["password"],
                "Teacher"
            )
        )


        user_id = cursor.lastrowid



        # Insert into teachers table

        teacher_query = """
        INSERT INTO teachers
        (
            user_id,
            employee_id,
            subject,
            qualification,
            experience,
            phone_number,
            gender,
            date_of_birth,
            joining_date
        )

        VALUES
        (
            %s,
            %s,
            %s,
            %s,
            %s,
            %s,
            %s,
            %s,
            %s
        )
        """


        cursor.execute(
            teacher_query,
            (
                user_id,
                data["employee_id"],
                data["subject"],
                data["qualification"],
                data["experience"],
                data["phone_number"],
                data["gender"],
                data["date_of_birth"],
                data["joining_date"]
            )
        )


        connection.commit()


        cursor.close()
        connection.close()


        return jsonify({

            "message":
            "Teacher added successfully"

        }), 201



    except Exception as e:


        return jsonify({

            "error": str(e)

        }), 500
        # ==========================
# UPDATE TEACHER
# ==========================

@teachers.route("/teachers/<int:id>", methods=["PUT"])
def update_teacher(id):

    try:

        data = request.json


        connection = get_connection()

        cursor = connection.cursor()



        # Update users table

        user_query = """
        UPDATE users u

        JOIN teachers t
        ON u.user_id = t.user_id

        SET
            u.full_name = %s,
            u.email = %s

        WHERE t.teacher_id = %s
        """


        cursor.execute(
            user_query,
            (
                data["full_name"],
                data["email"],
                id
            )
        )



        # Update teachers table

        teacher_query = """
        UPDATE teachers

        SET

            employee_id = %s,
            subject = %s,
            qualification = %s,
            experience = %s,
            phone_number = %s,
            gender = %s,
            date_of_birth = %s,
            joining_date = %s

        WHERE teacher_id = %s
        """


        cursor.execute(
            teacher_query,
            (
                data["employee_id"],
                data["subject"],
                data["qualification"],
                data["experience"],
                data["phone_number"],
                data["gender"],
                data["date_of_birth"],
                data["joining_date"],
                id
            )
        )


        connection.commit()


        cursor.close()
        connection.close()


        return jsonify({

            "message":
            "Teacher updated successfully"

        }), 200



    except Exception as e:

        return jsonify({

            "error": str(e)

        }), 500
        # ==========================
# DELETE TEACHER
# ==========================

# ==========================
# DELETE TEACHER
# ==========================

@teachers.route("/teachers/<int:id>", methods=["DELETE"])
def delete_teacher(id):

    try:

        connection = get_connection()

        cursor = connection.cursor()


        # Get user_id before deleting

        cursor.execute(
            """
            SELECT user_id
            FROM teachers
            WHERE teacher_id = %s
            """,
            (id,)
        )


        teacher = cursor.fetchone()


        if teacher is None:

            return jsonify({

                "message": "Teacher not found"

            }), 404


        user_id = teacher[0]
        
# Delete attendance records
        cursor.execute(
          """
          DELETE FROM attendance
          WHERE teacher_id = %s
          """,
          (id,)
        )

# Delete marks records
        cursor.execute(
           """
           DELETE FROM marks
           WHERE teacher_id = %s
           """,
           (id,)
        )

# Delete homework records
        cursor.execute(
           """
           DELETE FROM homework
           WHERE teacher_id = %s
           """,
           (id,)
        )

# Delete announcement records
        cursor.execute(
           """
           DELETE FROM announcements
           WHERE teacher_id = %s
           """,
           (id,)
        )
        # Delete from teachers table

        cursor.execute(
            """
            DELETE FROM teachers
            WHERE teacher_id = %s
            """,
            (id,)
        )


        # Delete from users table

        cursor.execute(
            """
            DELETE FROM users
            WHERE user_id = %s
            """,
            (user_id,)
        )


        connection.commit()


        cursor.close()
        connection.close()


        return jsonify({

            "message": "Teacher deleted successfully"

        }), 200


    except Exception as e:

        print("DELETE TEACHER ERROR:", e)

        return jsonify({

            "error": str(e)

        }), 500