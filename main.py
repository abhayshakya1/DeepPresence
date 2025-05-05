from fastapi import FastAPI, HTTPException, status, File, UploadFile, Form, Query
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
import mysql.connector
from typing import List, Optional
import os
from datetime import datetime
import cv2
import numpy as np
import torch
from PIL import Image
from pillow_heif import open_heif
from insightface.app import FaceAnalysis  # RetinaFace-based detector
from deepface import DeepFace
import pickle
import matplotlib.pyplot as plt
from sklearn.preprocessing import normalize
from sklearn.metrics.pairwise import cosine_similarity
from collections import defaultdict
import shutil
import glob
import hdbscan
import pandas as pd
from sklearn.metrics import confusion_matrix, accuracy_score
from typing import Optional
from geopy.distance import geodesic
import time
import uuid
from io import StringIO
import csv

app = FastAPI()

face_app = FaceAnalysis(name="buffalo_l", providers=['CPUExecutionProvider'])
face_app.prepare(ctx_id=0)  # 0 = CPU
min_cluster_size = 2
similarity_threshold = 0.30

last_request_time = {}
# Database connection settings
def get_db_connection():
    db = mysql.connector.connect(
        host="localhost",
        user="root",
        password="root@123",
        database="deeppresence"
    )
    return db
    
def heic_to_jpg(image_path):
    heif_file = open_heif(image_path)
    image = Image.frombytes(heif_file.mode, heif_file.size, heif_file.data)
    jpg_path = image_path.replace(".HEIC", ".jpg").replace(".heic", ".jpg")
    image.save(jpg_path, "JPEG")
    return jpg_path
    
def detect_faces_and_extract_embeddings(image_folder):
    face_data = []  # (embedding, image_path, bbox)
    for img_name in os.listdir(image_folder):
        if not img_name.lower().endswith(('.jpg', '.jpeg', '.png')):
            continue
        img_path = os.path.join(image_folder, img_name)
        image = cv2.imread(img_path)
        if image is None:
            print(f"Failed to load image: {img_path}")
            continue
        faces = face_app.get(image)
        for face in faces:
            embedding = face.embedding
            bbox = face.bbox.astype(int)  # [x1, y1, x2, y2]
            face_data.append((embedding, img_path, bbox))
    
    print(f"Total faces detected: {len(face_data)}")
    return face_data

def get_base_dir(course_name):
    BASE_UPLOAD_DIR = f"/Users/abhay/IIIT-Delhi/Semester-2/DL/DL Project/DLProject/DeepPresence/{course_name}_Local_image_store"
    return BASE_UPLOAD_DIR

def get_img_dir(course_name, image_path):
    BASE_UPLOAD_DIR = f"/Users/abhay/IIIT-Delhi/Semester-2/DL/DL Project/DLProject/DeepPresence/{course_name}_Local_image_store/{image_path}_"
    return BASE_UPLOAD_DIR

def detect_faces_and_extract_embeddings(image_folder):
    face_data = []  # (embedding, image_path, bbox)
    for img_name in os.listdir(image_folder):
        if not img_name.lower().endswith(('.jpg', '.jpeg', '.png')):
            continue
        img_path = os.path.join(image_folder, img_name)
        image = cv2.imread(img_path)
        if image is None:
            print(f"Failed to load image: {img_path}")
            continue
        faces = face_app.get(image)
        for face in faces:
            embedding = face.embedding
            bbox = face.bbox.astype(int)  # [x1, y1, x2, y2]
            face_data.append((embedding, img_path, bbox))
    
    print(f"Total faces detected: {len(face_data)}")
    return face_data

def normalize_embeddings(face_data):
    embeddings = np.array([fd[0] for fd in face_data])
    embeddings = normalize(embeddings)  # Normalize lecture embeddings
    return embeddings

# Step 3: Cluster using HDBSCAN
def cluster_faces(embeddings):
    clusterer = hdbscan.HDBSCAN(min_cluster_size=min_cluster_size, metric='euclidean')
    labels = clusterer.fit_predict(embeddings)
    return labels
    
def get_student_base_dir():
    BASE_UPLOAD_DIR = f"/Users/abhay/IIIT-Delhi/Semester-2/DL/DL Project/DLProject/DeepPresence/Local_Profileimage_store"
    return BASE_UPLOAD_DIR

def save_clusters(labels, face_data):
    clusters = defaultdict(list)
    for label, (embedding, img_path, bbox) in zip(labels, face_data):
        if label != -1:
            clusters[label].append((embedding, img_path, bbox))  # Store original embedding
    return clusters

def load_ground_truth_embeddings_from_sql(profile_images: List[tuple]):
    ground_truth_embeddings = {}
    
    for profile in profile_images:
        # Get profile image path
        print(profile[0])
        img_path = profile[0]
        
        # Load the image from the path
        image = cv2.imread(img_path)
        
        if image is None:
            print(f"Warning: Could not read image: {img_path}. Skipping.")
            continue
        
        # Detect faces using the face_app model
        faces = face_app.get(image)
        
        # If faces are detected, extract the embedding
        if faces:
            embedding = faces[0].embedding
            embedding = normalize([embedding])[0]  # Normalize the embedding
            
            # Extract the student name from the image path (without extension)
            student_name = os.path.splitext(os.path.basename(img_path))[0]
            ground_truth_embeddings[student_name] = embedding
        else:
            print(f"No face detected in ground truth image: {img_path}")
    
    print(f"Loaded {len(ground_truth_embeddings)} ground truth embeddings")
    return ground_truth_embeddings

def match_faces_to_students(clusters, ground_truth_embeddings):
    student_identifications = defaultdict(lambda: defaultdict(int))  # {cluster_id: {student_name: count}}
    attendance_info = []
    
    for label, faces in clusters.items():
        for embedding, img_path, bbox in faces:
            best_match = None
            best_similarity = -1
            best_student = None

            for student_name, student_embedding in ground_truth_embeddings.items():
                similarity = cosine_similarity([embedding], [student_embedding])[0][0]
                if similarity > best_similarity and similarity >= similarity_threshold:
                    best_similarity = similarity
                    best_student = student_name
            
            if best_student:
                student_identifications[label][best_student] += 1
            else:
                student_identifications[label]["Unidentified"] += 1
            
            print(f"Cluster {label}, Image {os.path.basename(img_path)}: Best match = {best_student}, Similarity = {best_similarity}")
            if best_student and best_student != 'Unidentified':
                attendance_info.append({
                    'cluster_no': label,
                    'filename': img_path,
                    'match': best_student,
                    'score': best_similarity
                })
    return student_identifications, attendance_info

def detect_faces(image_path):
    image = cv2.imread(image_path)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)  # Convert BGR to RGB
    
    # Detect faces using RetinaFace (from InsightFace)
    faces = face_app.get(image_rgb)

    return faces
def visualize_clusters(clusters, student_identifications, attendance_info, date, course_name):
    # Initialize attendance_info list to store attendance data

    # Iterate over clusters
    for idx, (label, faces) in enumerate(clusters.items()):
        # Identify the most identified student in the cluster
        if not student_identifications[label]:  # Skip empty clusters
            print(f"Cluster {label} has no valid matches. Skipping.")
            continue
        
        most_identified_student = max(student_identifications[label], key=student_identifications[label].get)
        identification_count = student_identifications[label][most_identified_student]
        cluster_size = len(faces)

        # Calculate attendance ratio and determine status
        attendance_ratio = identification_count / cluster_size
        status = 'Present' if attendance_ratio >= 0.5 else 'Absent'

        # Only add attendance data if the student is not "Unidentified"
        if most_identified_student != "Unidentified":
            # Database connection and attendance insertion
            try:
                db = get_db_connection()
                cursor = db.cursor()

                # Fetch email (login_id) based on the rollNumber (most_identified_student)
                cursor.execute(
                    "SELECT login_id FROM users WHERE rollNumber = %s", (most_identified_student,)
                )
                emailID = cursor.fetchone()  # fetchone since we expect only one result

                if emailID:
                    # Insert attendance record into the database
                    cursor.execute(
                        "INSERT INTO attendance (login_id, attendance_date, aStatus, sScore, rollNo, subject) "
                        "VALUES (%s, %s, %s, %s, %s, %s)",
                        (emailID[0], date, status, attendance_ratio, most_identified_student, course_name)
                    )
                    db.commit()
                else:
                    print(f"Warning: No email found for student with rollNumber {most_identified_student}")
                
            except mysql.connector.Error as e:
                print(f"Database error: {e}")
            except Exception as e:
                print(f"Error inserting attendance: {e}")
                    

    return attendance_info

    
class UploadImageRequest(BaseModel):
    date: str
    course_name: str

# User Model for Registration
class RegisterUser(BaseModel):
    login_type: str  # Example: "Instructor" or "Student"
    login_id: str  # User's email, validated as EmailStr
    password: str  # Plain text password
    name: str  # User's full name
    
class AbsenceQueryRequest(BaseModel):
    studentId: str
    courseName: str
    date: str
    latitude: float
    longitude: float

# User Model for Login (NO NAME field)
class LoginUser(BaseModel):
    login_type: str
    login_id: str  # User's email, validated as EmailStr
    password: str

# Course Model
class Course(BaseModel):
    course_name: str
    course_id: str
    semester: str
    
class Query(BaseModel):
    id: int
    date: str
    course_name: str
    student_id: str
    location: str
    created_at: str
    
class AttendanceAnalytics(BaseModel):
    date: str
    attendancePercentage: float

def rate_limit_check(course_name: str) -> bool:
    current_time = time.time()
    last_time = last_request_time.get(course_name, 0)
    if current_time - last_time < 5:  # 5 seconds rate limit
        return False
    last_request_time[course_name] = current_time
    return True


@app.post("/login")
def login_user(user: LoginUser):
    db = get_db_connection()
    cursor = db.cursor()

    # Fetch the password from the database (no hash comparison)
    cursor.execute(
        "SELECT password FROM users WHERE login_type = %s AND login_id = %s",
        (user.login_type, user.login_id)
    )
    db_password = cursor.fetchone()
    
    if db_password and db_password[0] == user.password:
        return {"message": "Login successful"}
    raise HTTPException(status_code=401, detail="Invalid credentials")
    



@app.get("/courses/{instructor_id}")
def get_courses(instructor_id: str):
    db = get_db_connection()
    cursor = db.cursor()

    # Fetch courses for the specific instructor
    cursor.execute("SELECT courseName, courseCode, semester FROM instructorCourses WHERE login_id = %s AND courseStatus = 'ongoing'", (instructor_id,))
    result = cursor.fetchall()

    if not result:
        raise HTTPException(status_code=404, detail="No ongoing courses found")

    # Construct the list of courses
    courses = [{"course_name": row[0], "course_id": row[1], "semester": row[2]} for row in result]
    return courses
    
@app.post("/uploadProfilePicture")
async def upload_image_with_face_check(
    student_id: str = Form(...),  # Ensure student_id is passed correctly as a string
    image: UploadFile = File(...)  # Expecting image as a file
):
    print(f"student_id: {student_id}, image: {image.filename}")
    try:
        # Ensure that student_id is valid
        if not student_id:
            raise HTTPException(status_code=400, detail="Student ID is required.")
        
        # Get the base directory for storing images
        date_folder = get_student_base_dir()  # Replace with actual path

        # Validate image format
        file_extension = os.path.splitext(image.filename)[1].lower()
        if file_extension not in ['.jpg', '.jpeg', '.png', '.heic', '.heif']:
            raise HTTPException(status_code=400, detail="Invalid image format. Only JPG, JPEG, PNG, HEIC are allowed.")
        
        # Get the rollNumber from the database using the student_id
        db = get_db_connection()
        cursor = db.cursor()
        cursor.execute(
            "SELECT rollNumber FROM users WHERE login_id = %s", (student_id,)
        )
        result = cursor.fetchall()

        # Check if a rollNumber was returned
        if not result:
            raise HTTPException(status_code=404, detail="Student not found.")

        roll_number = result[0][0]  # Extract the rollNumber from the result
        file_path = os.path.join(date_folder, f"{roll_number}.jpg")  # Unique file name

        # Save the uploaded image to the server
        with open(file_path, "wb") as image_file:
            image_file.write(await image.read())

        # Convert HEIC to JPG if necessary
        if file_extension in ['.heic', '.heif']:
            file_path = heic_to_jpg(file_path)

        # Detect faces in the uploaded image
        faces = detect_faces(file_path)

        # Check if exactly one face is detected
        if len(faces) != 1:
            raise HTTPException(status_code=400, detail="Multiple faces detected. Please upload an image with only one face.")

        # Update the user's profile image path in the database
        cursor.execute(
            "UPDATE `deeppresence`.`users` SET `profileImage` = %s WHERE `login_id` = %s",
            (file_path, student_id)
        )
        db.commit()


        return {
            "message": "Image uploaded successfully with a single face detected.",
            "file_path": file_path
        }

    except mysql.connector.Error as db_error:
        raise HTTPException(status_code=500, detail=f"Database error: {str(db_error)}")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")

@app.post("/upload_image")
async def upload_image(
    date: str = Form(...),
    course_name: str = Form(...),
    images: List[UploadFile] = File(...),
    latitude: str = Form(None),  # Make optional
    longitude: str = Form(None)
    ):
    print(f"Received date: {date}, course_name: {course_name}, images: {len(images)}")
    try:
        lat = float(latitude) if latitude else None
        lng = float(longitude) if longitude else None
        
        BASE_UPLOAD_DIR = get_base_dir(course_name)
        date_folder = os.path.join(BASE_UPLOAD_DIR, date)
        os.makedirs(date_folder, exist_ok=True)

        for image in images:
            file_path = os.path.join(date_folder, f"{date}_{image.filename}")
            with open(file_path, "wb") as image_file:
                image_file.write(await image.read())
        db = get_db_connection()
        cursor = db.cursor()
        cursor.execute(
                "INSERT INTO imagesUploads (date, courseName, imagePath, longitude, latitude) VALUES (%s, %s, %s, %s, %s)",
                (date, course_name, date_folder, lat, lng)
            )
        db.commit()

        face_data = detect_faces_and_extract_embeddings(date_folder)
        embeddings = normalize_embeddings(face_data)
        labels = cluster_faces(embeddings)
        clusters = save_clusters(labels, face_data)
        db = get_db_connection()
        cursor = db.cursor()
        cursor.execute(
            "SELECT u.profileImage AS profile_image FROM studentCourses sc JOIN users u ON sc.login_id = u.login_id WHERE sc.courseName = %s", (course_name,)
        )
        profile_images = cursor.fetchall()
        db.commit()

        ground_truth_embeddings = load_ground_truth_embeddings_from_sql(profile_images)
        print(len(ground_truth_embeddings))
        student_identifications, attendance_info = match_faces_to_students(clusters, ground_truth_embeddings)
        visualize_clusters(clusters, student_identifications, attendance_info, date, course_name)

        return {"message": "Images uploaded, faces detected, and saved successfully",
                "file_paths": date_folder,
                "latitude": lat,
                "longitude": lng}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")




@app.get("/studentCourses/{student_id}")
def get_courses(student_id: str):
    db = get_db_connection()
    cursor = db.cursor()

    # Fetch courses for the specific instructor
    cursor.execute("SELECT courseName, courseCode, semester FROM studentCourses WHERE login_id = %s AND courseStatus = 'ongoing'", (student_id,))
    result = cursor.fetchall()
    db.commit()

    if not result:
        raise HTTPException(status_code=404, detail="No ongoing courses found")

    # Construct the list of courses
    courses = [{"course_name": row[0], "course_id": row[1], "semester": row[2]} for row in result]
    return courses
    
@app.get("/attendance/{course}/{student_id}")
def get_attendance(student_id: str, course: str):
    db = get_db_connection()
    cursor = db.cursor()

    # Fetch courses for the specific instructor
    cursor.execute("SELECT attendance_date, aStatus FROM attendance WHERE login_id = %s AND subject = %s", (student_id, course))
    result = cursor.fetchall()
    print(result)
    db.commit()
    if not result:
        raise HTTPException(status_code=404, detail="No ongoing courses found")

    # Format date to string format (YYYY-MM-DD)
    attendance = [{"date": row[0].strftime('%Y-%m-%d'), "status": row[1]} for row in result]
    return attendance

@app.post("/query_absence")
async def query_absence(request: AbsenceQueryRequest):
    # Log the data received (you can replace this with actual database or other operations)
    print(f"Query received for student {request.studentId} in course {request.courseName} on {request.date}")
    print(f"Location: ({request.latitude}, {request.longitude})")
    
    db = get_db_connection()
    cursor = db.cursor()

    # Fetch courses for the specific instructor
    cursor.execute("SELECT DISTINCT longitude, latitude FROM imagesUploads WHERE date = %s AND courseName = %s", (request.date, request.courseName))
    result = cursor.fetchall()
    print(result)
    db.commit()

    # Example fixed location (latitude and longitude of the school)
    school_location = (result[0][0], result[0][1])  # Replace with actual school coordinates
    
    student_location = (request.latitude, request.longitude)
    
    # Calculate the distance between the school and student
    distance = geodesic(school_location, student_location).kilometers
    
    if distance > .01:
        db = get_db_connection()
        cursor = db.cursor()
        cursor.execute(
                "INSERT INTO attendanceQuery (date, courseName, student_id, location) VALUES (%s, %s, %s, %s)",
                (request.date, request.courseName, request.studentId, 'NOT IN')
            )
        db.commit()# Example: If the student is more than 1 km away, mark as suspicious
        return {"message": "Query received, but student location seems far from school."}
    db = get_db_connection()
    cursor = db.cursor()
    cursor.execute(
            "INSERT INTO attendanceQuery (date, courseName, student_id, location) VALUES (%s, %s, %s, %s)",
            (request.date, request.courseName, request.studentId, 'IN')
        )
        
    db.commit()
    # Otherwise, handle the absence query as normal
    return {"message": "Absence query successful", "studentId": request.studentId}
    
@app.get("/queries", response_model=List[Query])
async def get_queries():
    try:
        db = get_db_connection()
        cursor = db.cursor(dictionary=True)
        cursor.execute(
            "SELECT id, DATE_FORMAT(date, '%Y-%m-%d') as date, courseName as course_name,student_id, location, DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at FROM attendanceQuery ORDER BY created_at DESC")
        results = cursor.fetchall()
        db.commit()
        
        return results
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
        
        
@app.get("/students/{course_name}")
def get_students(course_name: str) -> List[str]:
    """Fetch the list of students for the given course_name"""
    try:
        db = get_db_connection()
        cursor = db.cursor(dictionary=True)
        cursor.execute(
            "SELECT DISTINCT rollNo FROM attendance WHERE subject = %s",
            (course_name,)
        )
        students = cursor.fetchall()
        db.commit()

        # Return just the rollNo as a list of strings
        return [student['rollNo'] for student in students]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/dates/{course_name}")
def get_dates(course_name: str) -> List[str]:
    """Fetch the list of dates for the given course_name"""
    try:
        db = get_db_connection()
        cursor = db.cursor(dictionary=True)
        print(f"Executing query for course: {course_name}")  # Debug log
        cursor.execute(
            "SELECT DISTINCT attendance_date FROM attendance WHERE subject = %s",
            (course_name,)
        )
        dates = cursor.fetchall()
        print(f"Found dates: {dates}")  # Debug log
        db.commit()
        return [date['attendance_date'].strftime('%Y-%m-%d') for date in dates]  # Ensure proper date formatting
    except Exception as e:
        print(f"Error in get_dates: {str(e)}")  # Debug log
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if db and db.is_connected():
            cursor.close()
            db.close()

@app.get("/analytics/{course_name}", response_model=List[AttendanceAnalytics])
async def get_analytics(course_name: str, student: Optional[str] = None, date: Optional[str] = None):
    if not rate_limit_check(course_name):
        raise HTTPException(status_code=429, detail="Rate limit exceeded. Please wait 5 seconds.")
    
    try:
        db = get_db_connection()
        cursor = db.cursor()
        
        # Base query to calculate attendance percentage
        query = """
            SELECT attendance_date, 
                   AVG(CASE WHEN aStatus = 'Present' THEN 1.0 ELSE 0.0 END) * 100 as attendancePercentage
            FROM attendance
            WHERE subject = %s
        """
        params = [course_name]
        
        # Add filters if provided
        if student:
            query += " AND rollNo = %s"
            params.append(student)
        if date:
            query += " AND attendance_date = %s"
            params.append(date)
            
        query += " GROUP BY attendance_date ORDER BY attendance_date"
        
        cursor.execute(query, params)
        results = cursor.fetchall()
        
        # Convert to AttendanceAnalytics format
        analytics = [
            AttendanceAnalytics(
                date=row[0].strftime('%Y-%m-%d'),
                attendancePercentage=float(row[1])
            )
            for row in results
        ]
        
        db.commit()
        cursor.close()
        db.close()
        return analytics
        
    except mysql.connector.Error as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")
        
@app.get("/download_csv/")
def download_csv(course_name: str, date: str):
    db = get_db_connection()
    cursor = db.cursor()

    query = """
    SELECT rollNo, aStatus, attendance_date 
    FROM attendance 
    WHERE subject = %s AND attendance_date = %s
    """
    cursor.execute(query, (course_name, date))
    attendance_data = cursor.fetchall()
    db.close()

    output = StringIO()
    writer = csv.writer(output)
    writer.writerow(["Roll Number", "Status", "Date"])
    for row in attendance_data:
        writer.writerow(row)

    output.seek(0)
    filename = f"{course_name}_{date}.csv"

    return StreamingResponse(
        output,
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )

