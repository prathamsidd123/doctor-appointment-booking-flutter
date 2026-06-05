# 🏥 Doctor Appointment Booking App

**DLiveHealthy** is a Flutter-based healthcare application designed to connect patients and doctors through a simple and efficient appointment management system. Patients can create accounts, manage their profiles, and request appointments, while doctors can review, accept, or reject appointment requests and manage their professional information. The application uses Firebase Authentication for secure login and Firebase Realtime Database for real-time data storage and synchronization, ensuring a seamless healthcare experience for both patients and doctors.


## 📱 Features

### 👨‍⚕️ Doctor Module

* Doctor Registration & Login
* Doctor Profile Management
* View Appointment Requests
* Accept/Reject Appointment Requests

### 🧑‍🤝‍🧑 Patient Module

* Patient Registration & Login
* Search Doctors
* Book Appointments
* View Appointment Status

### 🔐 Authentication

* Firebase Authentication
* Email & Password Login
* Password Reset via Email
* Secure User Sessions

### ☁️ Database

* Firebase Realtime Database
* Real-time Data Synchronization
* Secure User Data Storage

## 🛠️ Technologies Used

* Flutter
* Dart
* Firebase Authentication
* Firebase Realtime Database
* Material Design


## 🚀 Installation

### 1. Clone Repository

```bash
git clone https://github.com/your-username/doctor-appointment-booking.git
```

### 2. Navigate to Project

```bash
cd doctor-appointment-booking
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

1. Create a Firebase Project.
2. Enable Authentication (Email/Password).
3. Enable Realtime Database.
4. Download:

   * google-services.json (Android)
   * GoogleService-Info.plist (iOS)
5. Place files in appropriate directories.
6. Add this rules {
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
    
    "Requests": {
      ".indexOn": ["sender", "doctorId"]
    },
    "Doctors": {
      ".indexOn": ["uid", "category"]
    }
  }
}

## 📸 Screenshots
<img width="2995" height="1027" alt="Screenshot from 2026-06-04 20-31-56-imageonline co-merged" src="https://github.com/user-attachments/assets/ac219114-64ae-4384-9987-2530221051c7" />

