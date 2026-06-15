CREATE DATABASE face_attendance_system;
USE face_attendance_system;
CREATE TABLE admin (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(100)
);
CREATE TABLE department (
	department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100),
    department_code VARCHAR(50) UNIQUE,
    admin_id INT,
    FOREIGN KEY (admin_id) REFERENCES admin(admin_id) 
);
CREATE TABLE teachers (
	teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);
CREATE TABLE classes (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    roll_no VARCHAR(50),
    phone VARCHAR(15),
    class_id INT,
    face_encoding TEXT,
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
);
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100),
    teacher_id INT,
    class_id INT,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id),
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
);
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    date DATE,
    time TIME,
    status VARCHAR(10),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);



