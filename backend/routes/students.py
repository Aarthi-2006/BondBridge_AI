from flask import Blueprint, jsonify, request
from database import get_connection


students = Blueprint("students", __name__)




# =====================================
# GET ALL STUDENTS
# =====================================

# =====================================
# GET ALL STUDENTS
# =====================================

@students.route("/students", methods=["GET"])
def get_students():

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:

        student_class = request.args.get("class")
        section = request.args.get("section")
       
        query = """
        SELECT
            s.student_id,
            u.full_name,
            u.email,
            s.roll_no,
            s.class,
            s.section,
            s.gender,
            s.date_of_birth,
            s.admission_date
        FROM students s
        JOIN users u
        ON s.user_id = u.user_id
        """

        values = ()

        if student_class and section:
            query += """
            WHERE s.class=%s
            AND s.section=%s
            """
            values = (student_class, section)

        query += """
        ORDER BY
        s.class,
        s.section,
        CAST(s.roll_no AS UNSIGNED)
        """

        cursor.execute(query, values)

        data = cursor.fetchall()

        return jsonify(data)

    except Exception as e:

        return jsonify({
            "message": str(e)
        }), 500

    finally:

        cursor.close()
        connection.close()

@students.route("/students/count", methods=["GET"])
def get_student_count():

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:

        cursor.execute("""
            SELECT COUNT(*) AS total_students
            FROM students
        """)

        result = cursor.fetchone()

        return jsonify(result)

    except Exception as e:

        return jsonify({
            "message": str(e)
        }), 500

    finally:

        cursor.close()
        connection.close()




# =====================================
# ADD STUDENT
# =====================================


@students.route("/students", methods=["POST"])
def add_student():


    data = request.json



    connection = get_connection()

    cursor = connection.cursor()



    try:



        # Insert into users table

        user_query = """

        INSERT INTO users

        (full_name,email,password,role)

        VALUES(%s,%s,%s,%s)

        """



        user_values = (

            data["full_name"],

            data["email"],

            data["password"],

            "student"

        )



        cursor.execute(

            user_query,

            user_values

        )



        user_id = cursor.lastrowid





        # Insert into students table


        student_query = """

        INSERT INTO students

        (

        user_id,

        roll_no,

        class,

        section,

        date_of_birth,

        gender,

        admission_date

        )


        VALUES

        (%s,%s,%s,%s,%s,%s,%s)

        """




        student_values = (

            user_id,

            data["roll_no"],

            data["class"],

            data["section"],

            data["date_of_birth"],

            data["gender"],

            data["admission_date"]

        )




        cursor.execute(

            student_query,

            student_values

        )



        connection.commit()



        return jsonify({

            "message":

            "Student added successfully"

        })





    except Exception as e:



        connection.rollback()



        error_message = str(e)



        # Duplicate roll number error


        if "unique_student_roll" in error_message:



            return jsonify({

                "message":

                "Student with this Roll No already exists in this Class and Section"

            }),400





        # Duplicate email error


        if "email" in error_message:



            return jsonify({

                "message":

                "Email already exists"

            }),400




        return jsonify({

            "message": error_message

        }),500





    finally:


        cursor.close()

        connection.close()







# =====================================
# UPDATE STUDENT
# =====================================


@students.route("/students/<int:student_id>", methods=["PUT"])

def update_student(student_id):


    data = request.json



    connection = get_connection()

    cursor = connection.cursor()



    try:



        # Update users table


        user_query = """

        UPDATE users u


        JOIN students s

        ON u.user_id = s.user_id


        SET

        u.full_name=%s,

        u.email=%s


        WHERE s.student_id=%s

        """




        cursor.execute(

            user_query,

            (

                data["full_name"],

                data["email"],

                student_id

            )

        )







        # Update students table



        student_query = """

        UPDATE students


        SET

        roll_no=%s,

        class=%s,

        section=%s,

        gender=%s,

        date_of_birth=%s


        WHERE student_id=%s


        """




        cursor.execute(

            student_query,

            (

                data["roll_no"],

                data["class"],

                data["section"],

                data["gender"],

                data.get("date_of_birth"),

                student_id

            )

        )





        connection.commit()




        return jsonify({

            "message":

            "Student updated successfully"

        })






    except Exception as e:



        connection.rollback()



        if "unique_student_roll" in str(e):


            return jsonify({

                "message":

                "Another student already has this Roll No in this Class and Section"

            }),400




        return jsonify({

            "message":str(e)

        }),500





    finally:


        cursor.close()

        connection.close()







# =====================================
# DELETE STUDENT
# =====================================


@students.route("/students/<int:student_id>", methods=["DELETE"])

def delete_student(student_id):



    connection = get_connection()

    cursor = connection.cursor()



    try:



        # get user id first


        cursor.execute(

            """

            SELECT user_id

            FROM students

            WHERE student_id=%s

            """,

            (student_id,)

        )



        result = cursor.fetchone()



        if not result:



            return jsonify({

                "message":

                "Student not found"

            }),404




        user_id = result[0]





        # delete student


        cursor.execute(

            """

            DELETE FROM students

            WHERE student_id=%s

            """,

            (student_id,)

        )





        # delete user account


        cursor.execute(

            """

            DELETE FROM users

            WHERE user_id=%s

            """,

            (user_id,)

        )




        connection.commit()




        return jsonify({

            "message":

            "Student deleted successfully"

        })






    except Exception as e:



        connection.rollback()



        return jsonify({

            "message":str(e)

        }),500





    finally:


        cursor.close()

        connection.close()