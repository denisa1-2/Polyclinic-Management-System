# Polyclinic-Management-System

This project was developed as part of the university course **Introduction to Databases**.
The goal of the application is to simulate the management activities of a network of polyclinics, using a Java GUI and a MySQL database.

---

## Project Objectives

The main goals of the system are:

- managing users, roles and permissions
- managing medical staff and clinic locations
- appointment scheduling and medical reporting
- financial activity tracking
- GUI interaction only (no direct DB access)
- integration with a MySQL DBMS

All functionalities were developed based on the official project specification. 

---

## Core Features

### Authentication
- login based on username/password
- logout functionality
- automatic role-based access

### User & Role Management
- multiple employee types
- restricted access based on permissions (RBAC)
- view personal information

## HR Module
- search employees
- weekly schedules
- monthly schedules
- vacation registration
- view working hours

### Financial Module
- monthly profit calculations
- view revenues & expenses
- profit per doctor / location / specialty

### Operational Module
- patient appointment scheduling
- patient check-in
- fiscal receipt issuing
- creating medical reports
- viewing patient medical history

---

## Architecture Overview

**Application Layers**
- GUI layer (Java Swing)
- Business logic layer
- Data access layer (DAO + JDBC)
- MySQL relational database layer

---

## Database

The database was designed according to the academic requirements:
normalized structure, primary & foreign keys, referential integrity, populated dataset. 


### Included SQL scripts:
- table creation
- inserts
- stored procedures
- triggers
- SQL views

All SQL scripts are included in the `/database` folder for easy import.

The structure follows the academic specification that requires a multi-table schema reflecting real-world medical activity and a diverse set of users and permissions. 

---

## Project Structure
```
/src
    /model
    /service
    /repository
    /gui

/database
    tabele.sql
    populare.sql
    proceduri.sql
    triggere.sql
    vederi.sql
```

---

## Technologies Used

- Java
- Java Swing (GUI)
- JDBC
- MySQL
- SQL (Triggers, Stored Procedures, Views)

--- 


## How to Run the Project

### 1. Clone the repository:
```bash
git clone https://github.com/denisa1-2/Polyclinic-Management-System.git
```

### 2. Import the project into IntelliJ IDEA
### 3. Create a MySQL schema manually
### 4. Execute the SQL scripts in the following order:
1. tabele.sql
2. populare.sql
3. proceduri.sql
4. triggere.sql
5. vederi.sql
### 5. Configure database credentials inside the application source files
### 6. Run the application from Main.java
