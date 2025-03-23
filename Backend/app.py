from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
import bcrypt

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Connect to MongoDB
client = MongoClient("mongodb://localhost:27017/")
db = client["deep_presence"]

# Routes for Instructors
@app.route("/instructors", methods=["GET", "POST"])
def handle_instructors():
    if request.method == "GET":
        # Fetch all instructors
        instructors = list(db.instructors.find({}, {"_id": 0}))
        return jsonify(instructors), 200
    elif request.method == "POST":
        # Register a new instructor
        data = request.json
        email = data["email"]
        password = data["password"]

        # Validate instructor email (no numbers allowed)
        if any(char.isdigit() for char in email.split("@")[0]):
            return jsonify({"error": "Invalid instructor email. Email must not contain numbers."}), 400

        # Hash the password
        hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())

        # Insert the instructor into the database
        db.instructors.insert_one({
            "name": data["name"],
            "email": email,
            "password": hashed_password,
            "courses": data.get("courses", [])
        })
        return jsonify({"message": "Instructor registered successfully"}), 201

# Routes for Students
@app.route("/students", methods=["GET", "POST"])
def handle_students():
    if request.method == "GET":
        # Fetch all students
        students = list(db.students.find({}, {"_id": 0}))
        return jsonify(students), 200
    elif request.method == "POST":
        # Register a new student
        data = request.json
        email = data["email"]
        password = data["password"]

        # Hash the password
        hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())

        # Insert the student into the database
        db.students.insert_one({
            "name": data["name"],
            "email": email,
            "password": hashed_password,
            "courses": data.get("courses", [])
        })
        return jsonify({"message": "Student registered successfully"}), 201

# Routes for Courses
@app.route("/courses", methods=["GET", "POST"])
def handle_courses():
    if request.method == "GET":
        # Fetch all courses
        courses = list(db.courses.find({}, {"_id": 0}))
        return jsonify(courses), 200
    elif request.method == "POST":
        # Create a new course
        data = request.json
        db.courses.insert_one({
            "courseName": data["courseName"],
            "courseId": data["courseId"],
            "semester": data["semester"],
            "instructorEmail": data["instructorEmail"],
            "instructorName": data["instructorName"],
            "students": data.get("students", []),
            "enrolledStudentsCount": data.get("enrolledStudentsCount", 0)
        })
        return jsonify({"message": "Course created successfully"}), 201

if __name__ == "__main__":
    app.run(debug=True)
