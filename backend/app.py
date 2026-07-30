from flask import Flask
from routes.auth import auth
from routes.students import students
from routes.teachers import teachers
from routes.parents import parents
from routes.attendance import attendance
from routes.marks import marks
from routes.homework import homework
from routes.announcements import announcements

app = Flask(__name__)

app.register_blueprint(auth)
app.register_blueprint(students)
app.register_blueprint(teachers)
app.register_blueprint(parents)
app.register_blueprint(attendance)
app.register_blueprint(marks)
app.register_blueprint(homework)
app.register_blueprint(announcements)

@app.route("/")
def home():
    return "BondBridge AI Backend Running Successfully!"

if __name__ == "__main__":
    app.run(debug=True)