-- Crear la tabla STUDENT
CREATE TABLE student (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    nif VARCHAR(15)
);

ALTER TABLE owner
ADD CONSTRAINT unique_email_student UNIQUE (email);

-- Crear la tabla TEACHER
CREATE TABLE teacher (
    teacher_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    nif VARCHAR(15),
    speciality VARCHAR(100)
);

ALTER TABLE owner
ADD CONSTRAINT unique_email_teacher UNIQUE (email);

-- Crear la tabla COURSE
CREATE TABLE course (
    course_id SERIAL PRIMARY KEY,
    student_id INT,
    teacher_id INT,
    name VARCHAR(100),
    description VARCHAR(255),
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id),
    FOREIGN KEY (teacher_id) REFERENCES TEACHER(teacher_id)
);

-- Crear la tabla THEME
CREATE TABLE theme (
    theme_id SERIAL PRIMARY KEY,
    course_id INT,
    teacher_id INT,
    name VARCHAR(100),
    description VARCHAR(255),
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id),
    FOREIGN KEY (teacher_id) REFERENCES TEACHER(teacher_id)
);

-- Crear la tabla RESOURCES
CREATE TABLE resources (
    resources_id SERIAL PRIMARY KEY,
    theme_id INT,
    type VARCHAR(100),
    description VARCHAR(255),
    url VARCHAR(255),
    FOREIGN KEY (theme_id) REFERENCES THEME(theme_id)
);

-- Crear la tabla ENROLLMENT
CREATE TABLE enrollment (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id),
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id)
);

CREATE INDEX idx_enrollment_date ON enrollment (enrollment_date);