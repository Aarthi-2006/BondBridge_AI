from flask import Blueprint, request, jsonify
from database import get_connection

parents = Blueprint("parents", __name__)


# ==================================================
# GET ALL PARENTS + FILTER CLASS AND SECTION
# ==================================================

@parents.route("/parents", methods=["GET"])
def get_parents():

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        class_name = request.args.get("class")
        section = request.args.get("section")
        search = request.args.get("search")


        query = """
        SELECT 
            p.parent_id,
            u.full_name AS parent_name,
            u.email,

            s.student_id,
            su.full_name AS student_name,

            s.class,
            s.section,

            p.relationship

        FROM parents p

        JOIN users u
        ON p.user_id = u.user_id

        JOIN students s
        ON p.student_id = s.student_id

        JOIN users su
        ON s.user_id = su.user_id

        WHERE 1=1
        """


        params = []


        if class_name:
            query += " AND s.class = %s "
            params.append(class_name)


        if section:
            query += " AND s.section = %s "
            params.append(section)


        if search:
            query += """
            AND (
                u.full_name LIKE %s
                OR su.full_name LIKE %s
                OR u.email LIKE %s
            )
            """

            search_value = "%" + search + "%"

            params.extend([
                search_value,
                search_value,
                search_value
            ])


        cursor.execute(query, params)

        data = cursor.fetchall()


        return jsonify({
            "total": len(data),
            "parents": data
        })


    except Exception as e:

        return jsonify({
            "error": str(e)
        }),500



# ==================================================
# GET STUDENTS BY CLASS AND SECTION
# ==================================================

@parents.route("/parent_students", methods=["GET"])
def get_parent_students():

    try:

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)


        class_name = request.args.get("class")
        section = request.args.get("section")


        query = """
        SELECT

        s.student_id,

        u.full_name AS student_name,

        s.class,

        s.section


        FROM students s

        JOIN users u

        ON s.user_id = u.user_id


        WHERE s.class=%s

        AND s.section=%s

        """


        cursor.execute(
            query,
            (
                class_name,
                section
            )
        )


        students = cursor.fetchall()


        return jsonify(students)


    except Exception as e:

        return jsonify({
            "error":str(e)
        }),500




# ==================================================
# ADD PARENT
# ==================================================

@parents.route("/parents", methods=["POST"])
def add_parent():

    try:

        data=request.json


        conn=get_connection()

        cursor=conn.cursor()


        # create user

        user_query="""

        INSERT INTO users
        (
        full_name,
        email,
        password,
        role
        )

        VALUES
        (%s,%s,%s,'Parent')

        """


        cursor.execute(
            user_query,
            (
                data["full_name"],
                data["email"],
                data["password"]
            )
        )


        user_id=cursor.lastrowid



        # create parent

        parent_query="""

        INSERT INTO parents
        (
        user_id,
        student_id,
        relationship
        )

        VALUES
        (%s,%s,%s)

        """


        cursor.execute(
            parent_query,
            (
                user_id,
                data["student_id"],
                data["relationship"]
            )
        )


        conn.commit()


        return jsonify({
            "message":"Parent added successfully"
        })


    except Exception as e:

        return jsonify({
            "error":str(e)
        }),500




# ==================================================
# UPDATE PARENT
# ==================================================

@parents.route("/parents/<int:parent_id>", methods=["PUT"])
def update_parent(parent_id):

    try:

        data=request.json


        conn=get_connection()

        cursor=conn.cursor()


        cursor.execute(
            """
            SELECT user_id 
            FROM parents
            WHERE parent_id=%s
            """,
            (parent_id,)
        )


        user=cursor.fetchone()


        if not user:

            return jsonify({
                "message":"Parent not found"
            }),404



        user_id=user[0]


        cursor.execute(
            """
            UPDATE users

            SET full_name=%s,
            email=%s

            WHERE user_id=%s

            """,
            (
                data["full_name"],
                data["email"],
                user_id
            )
        )



        cursor.execute(
            """
            UPDATE parents

            SET student_id=%s,
            relationship=%s

            WHERE parent_id=%s

            """,
            (
                data["student_id"],
                data["relationship"],
                parent_id
            )
        )


        conn.commit()


        return jsonify({
            "message":"Parent updated successfully"
        })


    except Exception as e:

        return jsonify({
            "error":str(e)
        }),500





# ==================================================
# DELETE PARENT
# ==================================================

@parents.route("/parents/<int:parent_id>", methods=["DELETE"])
def delete_parent(parent_id):

    try:

        conn=get_connection()

        cursor=conn.cursor()


        cursor.execute(
            """
            SELECT user_id
            FROM parents
            WHERE parent_id=%s
            """,
            (parent_id,)
        )


        user=cursor.fetchone()


        if not user:

            return jsonify({
                "message":"Parent not found"
            }),404



        user_id=user[0]


        cursor.execute(
            """
            DELETE FROM parents
            WHERE parent_id=%s
            """,
            (parent_id,)
        )


        cursor.execute(
            """
            DELETE FROM users
            WHERE user_id=%s
            """,
            (user_id,)
        )


        conn.commit()


        return jsonify({
            "message":"Parent deleted successfully"
        })


    except Exception as e:

        return jsonify({
            "error":str(e)
        }),500