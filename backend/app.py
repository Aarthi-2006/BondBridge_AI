from flask import Flask

from routes.students import students
from routes.teachers import teachers
from routes.parents import parents
from routes.attendance import attendance
from routes.marks import marks
from routes.homework import homework
from routes.announcements import announcements
from routes.auth import auth

app = Flask(__name__)

# Register routes
app.register_blueprint(students)
app.register_blueprint(teachers)
app.register_blueprint(parents)
app.register_blueprint(attendance)
app.register_blueprint(marks)
app.register_blueprint(homework)
app.register_blueprint(announcements)
app.register_blueprint(auth)

@app.route("/")
def home():
    return "Welcome to BondBridge AI Backend!"

print(app.url_map)


if __name__ == "__main__":
    app.run(debug=True)