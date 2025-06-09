# 🩺 Meditone - Medical Cabinet Management System

**Meditone** is a cross-platform medical appointment management system developed using **Laravel**, **Flutter**, and **ReactJS**. It provides a seamless experience for both patients and doctors via a mobile application, and a powerful web-based dashboard with role-based access for administration and clinic staff.

## 📱 Mobile App (Flutter)

The Flutter app is intended for **users (patients)** and **doctors**:

### Patient Features:
- Register/Login
- Browse doctors and services
- Book an appointment
- View their own medical records and prescriptions
- Cancel appointments

### Doctor Features:
- Login securely
- View their appointments
- Update appointment statuses
- Manage medical records
- Create and download prescriptions as PDF
- Update their profile

---

## 🖥 Web Dashboard (ReactJS + Laravel API)

The web dashboard includes **four roles** with different permissions:

### 1. Admin
- Manage doctors
- Manage medical assistants
- Manage services

### 2. Medecin (Doctor)
- Manage patient medical records
- View and update appointments
- Create/download prescriptions (PDF)
- Update doctor profile

### 3. Assistance (Assistant)
- Manage all appointments
- Update appointments
- Update assistant profile

### 4. User (Patient)
- Book appointments
- View personal medical records
- Cancel appointments
- View/download prescriptions (PDF)

---

## 🚀 Tech Stack

| Layer        | Technology        |
|--------------|-------------------|
| Backend API  | Laravel (Sanctum, REST API) |
| Frontend Web | ReactJS           |
| Mobile App   | Flutter           |
| Database     | MySQL             |
| Auth         | Laravel Sanctum + Role-based middleware |

---

## 🔐 Authentication & Role Management

Authentication is handled via **Laravel Sanctum** with specific abilities for each role:
- `admin`
- `medecin`
- `assistance`
- `web` (for patients)
