from flask import Flask
from routes.auth import auth
from routes.students import students
from routes.teachers import teachers
from routes.parents import parents
from routes.attendance import attendance
from routes.homework import homework
from routes.announcements import announcements
from routes.class_teacher import class_teacher
from routes.marks import marks_bp
from routes.ai_reports import ai_reports_bp

app = Flask(__name__)

app.register_blueprint(auth)
app.register_blueprint(students)
app.register_blueprint(teachers)
app.register_blueprint(parents)
app.register_blueprint(attendance)
app.register_blueprint(marks_bp)
app.register_blueprint(homework)
app.register_blueprint(ai_reports_bp)
app.register_blueprint(announcements)
app.register_blueprint(class_teacher)

@app.route("/")
def home():
    return "BondBridge AI Backend Running Successfully!"

if __name__ == "__main__":
    app.run(debug=True)