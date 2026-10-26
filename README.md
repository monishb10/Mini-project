# Student Activity Participation Pattern Mining System (SAPM)

> **College Final-Year Capstone Project**  
> Built with Flutter (Web & Multiplatform), Material 3, Provider State Management, GoRouter, and fl_chart.  
> Designed with clean separation of concerns and repository pattern, fully prepared for Firebase Authentication and Cloud Firestore integration in Part 2.

---

## 🎯 Project Overview

The **Student Activity Participation Pattern Mining System** addresses a fundamental challenge in collegiate institutions: understanding, analyzing, and predicting extracurricular and co-curricular engagement across academic branches.

By applying **Association Rule Mining (Apriori Algorithm)** and **Behavioral Clustering (K-Means Archetyping)** on student attendance data, the system uncovers:
1. **Behavioral Associations**: e.g., `{Python Workshop, Data Structures Bootcamp} => {National Hackathon}` (Confidence: 86%, Lift: 2.26x).
2. **Student Clusters**: Categorizes students into archetypes (*Tech Innovators*, *Cultural Leaders*, *Athletic Regulars*, *At-Risk Disengaged Cohort*).
3. **Proactive Academic Interventions**: Early warning rosters alerting faculty mentors of students falling below attendance and credit thresholds.
4. **Accreditation Readiness**: Audit-ready activity logs mapped to institutional standards (e.g., NAAC Metric 5.3, NBA Criteria).

---

## 🏗️ Architecture & Folder Structure

The project implements a **Feature-Based Clean Architecture** ensuring high cohesion, low coupling, and zero hardcoded credentials:

```
d:\MP\
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart         # Material 3 harmonious color palette & gradients
│   │   │   └── app_constants.dart      # Departments, categories, default thresholds
│   │   ├── theme/
│   │   │   ├── app_theme.dart          # Light & Dark themes with Google Fonts (Outfit & Inter)
│   │   │   └── theme_controller.dart   # Reactive theme toggle controller
│   │   ├── utils/
│   │   │   ├── responsive_layout.dart  # Desktop, Tablet, Mobile breakpoints
│   │   │   └── validators.dart         # Form validators (email, student roll, required)
│   │   └── widgets/
│   │       ├── app_card.dart           # Glassmorphic elevated container
│   │       ├── stat_card.dart          # KPI metric cards with trends & icons
│   │       ├── empty_state.dart        # Reusable empty data states with CTAs
│   │       ├── loading_state.dart      # Loading indicators
│   │       ├── error_state.dart        # Error fallbacks with retry actions
│   │       ├── page_header.dart        # Standard responsive page title & actions
│   │       ├── app_topbar.dart         # Search, notifications, theme switch, user menu
│   │       ├── app_sidebar.dart        # Collapsible responsive navigation bar & role switcher
│   │       └── app_shell.dart          # Master responsive layout wrapper
│   │
│   ├── features/
│   │   ├── auth/                       # Screen 1: Login & Authentication
│   │   │   ├── data/models/user_model.dart
│   │   │   ├── data/repositories/auth_repository.dart
│   │   │   └── presentation/screens/login_screen.dart
│   │   │
│   │   ├── dashboard/                  # Screens 2, 3, 4: Role-based Dashboards
│   │   │   └── presentation/screens/
│   │   │       ├── admin_dashboard_screen.dart
│   │   │       ├── faculty_dashboard_screen.dart
│   │   │       └── student_dashboard_screen.dart
│   │   │
│   │   ├── students/                   # Screen 5: Student Management
│   │   │   ├── data/models/student_model.dart
│   │   │   ├── data/repositories/student_repository.dart
│   │   │   ├── presentation/controllers/student_controller.dart
│   │   │   ├── presentation/screens/student_management_screen.dart
│   │   │   └── presentation/widgets/
│   │   │       ├── student_form_dialog.dart
│   │   │       └── student_details_dialog.dart
│   │   │
│   │   ├── events/                     # Screens 6 & 7: Event Management & Registration
│   │   │   ├── data/models/event_model.dart
│   │   │   ├── data/repositories/event_repository.dart
│   │   │   ├── presentation/controllers/event_controller.dart
│   │   │   ├── presentation/screens/event_management_screen.dart
│   │   │   ├── presentation/screens/event_registration_screen.dart
│   │   │   └── presentation/widgets/event_form_dialog.dart
│   │   │
│   │   ├── attendance/                 # Screen 8: Attendance Management
│   │   │   ├── data/models/attendance_model.dart
│   │   │   ├── data/repositories/attendance_repository.dart
│   │   │   ├── presentation/controllers/attendance_controller.dart
│   │   │   └── presentation/screens/attendance_management_screen.dart
│   │   │
│   │   ├── analytics/                  # Screen 9: Participation Analytics
│   │   │   ├── data/models/analytics_model.dart
│   │   │   ├── data/repositories/analytics_repository.dart
│   │   │   ├── presentation/controllers/analytics_controller.dart
│   │   │   └── presentation/screens/participation_analytics_screen.dart
│   │   │
│   │   ├── pattern_mining/             # Screen 10: Pattern Mining (Apriori & Clustering)
│   │   │   ├── data/models/pattern_mining_model.dart
│   │   │   ├── data/repositories/pattern_mining_repository.dart
│   │   │   ├── presentation/controllers/pattern_mining_controller.dart
│   │   │   └── presentation/screens/pattern_mining_screen.dart
│   │   │
│   │   ├── reports/                    # Screen 11: Institutional & Accreditation Reports
│   │   │   ├── data/models/report_model.dart
│   │   │   ├── data/repositories/report_repository.dart
│   │   │   ├── presentation/controllers/report_controller.dart
│   │   │   └── presentation/screens/reports_screen.dart
│   │   │
│   │   └── profile/                    # Screen 12: User Profile & System Settings
│   │       └── presentation/screens/profile_settings_screen.dart
│   │
│   ├── routing/
│   │   └── app_router.dart             # GoRouter configuration with ShellRoute & guards
│   └── main.dart                       # App entry point with MultiProvider setup
│
├── test/
│   ├── widget_test.dart                # UI smoke test
│   └── unit_test.dart                  # Model, repository & controller unit test suite
└── pubspec.yaml
```

---

## 🖥️ All 12 Screens Implemented

| # | Screen | Route | Description |
|---|---|---|---|
| 1 | **Login** | `/login` | Role tabs (Admin / Faculty / Student), credentials validation, and 1-click evaluation shortcuts. |
| 2 | **Admin Dashboard** | `/admin/dashboard` | Macro KPI metrics, Monthly Participation Trends line chart, Activity Domain Breakdown donut chart, and mined association alerts. |
| 3 | **Faculty Dashboard** | `/faculty/dashboard` | Department overview, Mentee Early Warning & Risk Roster, pending roll-calls, and direct counsel trigger. |
| 4 | **Student Dashboard** | `/student/dashboard` | Personalized activity credit progress toward degree requirements (Honours track), registered events, and mined Apriori event suggestions. |
| 5 | **Student Management** | `/students` | Filterable, searchable student roster, risk status tags, add student dialog, edit student, and full modal profile view. |
| 6 | **Event Management** | `/events` | Event catalog with live capacity occupancy bars, category filtering, search, and event creation modal dialog. |
| 7 | **Event Registration** | `/event-registration` | Student-facing catalog with seat trackers, category chips, and instant 1-click registration/cancellation. |
| 8 | **Attendance Management**| `/attendance` | Event selector, QR Scanner simulator (type roll number & instant verify), roll call status toggles (Present/Absent/Excused), and bulk check-in. |
| 9 | **Participation Analytics**| `/analytics` | Multi-dimensional analytics: Department comparison bar charts, month-by-month trajectory line chart, and domain share pie chart. |
| 10 | **Pattern Mining Engine** | `/pattern-mining` | Interactive Apriori parameter tuning (Min Support, Min Confidence, Min Lift sliders), discovered association rules, behavioral clusters, and algorithm guide. |
| 11 | **Accreditation Reports** | `/reports` | NAAC/NBA criteria compliance, at-risk mentoring rosters, credits audit, and simulated PDF/CSV/XLSX generation. |
| 12 | **Profile & Settings** | `/profile` | Account information editing, Dark/Light visual theme selector, system defaults, and quick role emulation shortcuts. |

---

## ⚡ Setup & How to Run

### Prerequisites
- Flutter SDK (3.24+ / 3.44+) with Dart 3.5+
- Google Chrome (or Edge) for Flutter Web

### Commands

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run in Debug Mode (Flutter Web)**:
   ```bash
   flutter run -d chrome
   ```

3. **Run Static Analysis (Zero Warnings)**:
   ```bash
   flutter analyze
   ```

4. **Run Unit & Widget Tests**:
   ```bash
   flutter test
   ```

5. **Build Production Web Bundle**:
   ```bash
   flutter build web
   ```

---

## 🔥 PART 2: FIREBASE INTEGRATION & ROLE-BASED AUTHENTICATION

### 1. Technology & Architecture
- **Firebase Authentication**: Email & password authentication with continuous `authStateChanges` session streaming.
- **Cloud Firestore**: Real-time NoSQL database storing user profiles (`users/{uid}`) and student rosters (`students/{id}`).
- **FlutterFire CLI**: Automated platform configuration generating `lib/firebase_options.dart`.
- **Firebase Emulator Suite**: Support for local auth (`localhost:9099`) and firestore (`localhost:8080`) testing.
- **Route Protection**: Role-based access guards implemented with `GoRouter` redirecting unauthorized attempts to `/unauthorized` (403 Access Restricted).

---

### 2. Exact Terminal Commands for Firebase Setup

#### A. Install Firebase Tools & FlutterFire CLI
```bash
# 1. Install Firebase CLI globally via npm
npm install -g firebase-tools

# 2. Login to your Google / Firebase Account
firebase login

# 3. Activate FlutterFire CLI globally in Dart
dart pub global activate flutterfire_cli
```

> **Note**: Ensure `C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin` (or `$HOME/.pub-cache/bin`) is in your system `PATH`.

#### B. Configure Firebase for the Flutter Project (Web & Multiplatform)
```bash
# Run in the project root (d:\MP)
flutterfire configure --project=<your-firebase-project-id> --platforms=web,android,ios
```
This automatically updates `lib/firebase_options.dart` with your verified project credentials.

#### C. Run Firebase Local Emulator Suite (Optional for Offline Testing)
```bash
# Start local Auth and Firestore emulators
firebase emulators:start
```
The application includes `FirebaseService.connectToEmulators(host: 'localhost', authPort: 9099, firestorePort: 8080)` to route traffic to local emulators.

---

### 3. User Roles & Permission Matrix

| Module / Route | Student | Faculty Advisor | Institutional Administrator |
|---|:---:|:---:|:---:|
| **Admin Dashboard** (`/admin/dashboard`) | ❌ (Redirect 403) | ❌ (Redirect 403) |  Full Access |
| **Faculty Dashboard** (`/faculty/dashboard`) | ❌ (Redirect 403) |  Departmental Focus |  Supervisory View |
| **Student Dashboard** (`/student/dashboard`) |  Personal Credits | ❌ (Redirect 403) |  Inspection View |
| **Students Roster** (`/students`) | ❌ (Redirect 403) |  Dept Students Only |  Institutional Roster |
| **Event Management** (`/events`) |  Browse Schedule |  Create/Edit Events |  Full Admin Control |
| **Event Registration** (`/event-registration`) |  Self-Register |  View Headcount |  Manage Registrations |
| **Attendance Roll Call** (`/attendance`) | ❌ (Redirect 403) |  Mark Roll-Call |  Audit Verification |
| **Participation Analytics** (`/analytics`) | ❌ (Redirect 403) |  Dept Analytics |  Campus Macro Trends |
| **Pattern Mining Engine** (`/pattern-mining`) | ❌ (Redirect 403) |  Run Algorithms |  Tune & Commit Rules |
| **Accreditation Reports** (`/reports`) | ❌ (Redirect 403) |  Draft Reports |  Approve & Export |
| **Profile & Settings** (`/profile`) |  Personal Profile |  Faculty Profile |  Administrator Profile |

---

### 4. Firestore Data Schema

#### `users/{uid}` Collection
```json
{
  "uid": "firebase_auth_uid_string",
  "email": "sarah.m@college.edu",
  "name": "Dr. Sarah Mitchell",
  "role": "admin", // 'admin', 'faculty', 'student'
  "department": "Computer Science & Engineering",
  "studentId": "", // Populated only for students (e.g. "22CS104")
  "avatarUrl": "",
  "status": "active", // 'active', 'pending_approval', 'suspended'
  "createdAt": "2025-01-01T00:00:00.000Z",
  "updatedAt": "2026-10-26T10:45:00.000Z"
}
```

---

### 5. Secure Initial Administrator Creation

#### Security Principle:
Public registration (`signUp`) strictly accepts **ONLY `student` and `faculty`** roles. Any attempt to pass `role: 'admin'` in public registration is rejected with a **Security Violation Exception** both client-side and enforced at the database level by `firestore.rules`.

#### Provisioning the First Admin:
1. **Method 1: Interactive Bootstrap Modal (Web UI)**
   - Click **"System Bootstrap: Initialize First Admin"** at the bottom of the Login Screen.
   - Enter Administrator Name, Email, Password, Department, and the verified **Administrative Setup Token** (`SAPM_INITIAL_ADMIN_TOKEN_2026`).
   - The token can be customized via `--dart-define=ADMIN_SETUP_TOKEN=your_secret`.

2. **Method 2: Standalone CLI Script**
   ```bash
   dart run scripts/create_initial_admin.dart \
     --email=admin@college.edu \
     --password=SecureAdminPassword123! \
     --name="Dr. Sarah Mitchell" \
     --dept="Office of the Principal" \
     --token=SAPM_INITIAL_ADMIN_TOKEN_2026
   ```

---

### 6. Cloud Firestore Security Rules (`firestore.rules`)

The `firestore.rules` file enforces:
- **Anti-Privilege Escalation**: Users cannot elevate their own role or mutate their `uid`, `email`, or `status`.
- **Public Registration Guard**: Public create rule allows users to create their own document if `role != 'admin'`.
- **Student Privacy**: Students can read only their own records (`resource.data.id == request.auth.uid`).
- **Departmental Isolation**: Faculty advisors can view students and mark attendance for their department.
- **Accreditation Secrecy**: Reports and audit data can only be modified by Faculty and Administrators.

---

### 7. Evaluation Quick Logins

The login screen features 1-click chips for instant evaluation:
- **Admin**: `admin@college.edu` (Dr. Sarah Mitchell - CSE)
- **Faculty**: `faculty@college.edu` (Prof. Rajesh Sharma - IT)
- **Student**: `student@college.edu` (Aarav Patel - Roll No: `22CS104`)

*(You can also quickly switch roles at any point from the top of the Sidebar or from the Profile & Settings screen).*

---

## 🚀 PART 3: CRUD OPERATIONS, REGISTRATIONS & ATTENDANCE

Part 3 implements complete production-grade CRUD workflows backed by Cloud Firestore with atomic transactions, validation guards, batch CSV parsing, and cryptographic QR attendance verification.

### 1. Updated Firestore Data Schemas

#### A. `students/{docId}` Collection
Protected master student roster. Mutations are strictly restricted to Administrators.
```json
{
  "id": "std_01",
  "studentId": "22CS101",
  "rollNumber": "22CS101",
  "name": "Aditya Sharma",
  "email": "aditya.s@college.edu",
  "department": "Computer Science & Engineering",
  "year": "3rd Year",
  "section": "A",
  "interests": ["Technical & Coding", "Hackathons & Ideathons", "Workshops & Seminars"],
  "preferredCategories": ["Technical & Coding", "Hackathons & Ideathons"],
  "cgpa": 8.92,
  "activityPoints": 280,
  "attendanceRate": 92.0,
  "clusterGroup": "Tech Innovators",
  "riskLevel": "Low",
  "createdAt": "2025-08-01T00:00:00.000Z",
  "enrolledAt": "2025-08-01T00:00:00.000Z"
}
```

#### B. `events/{eventId}` Collection
Institutional activities and workshops. Managed by Faculty Advisors and Administrators.
```json
{
  "id": "evt_01",
  "eventId": "evt_01",
  "title": "National Hackathon 2026: CodeSpark",
  "description": "36-hour flagship hackathon fostering interdisciplinary solutions in AI and IoT.",
  "category": "Technical", // Technical, Workshop, Seminar, Cultural, Sports, Social Service
  "department": "Computer Science & Engineering",
  "organizerDepartment": "Computer Science & Engineering",
  "venue": "Auditorium Complex & Innovation Hub",
  "startDate": "2026-10-30T09:00:00.000Z",
  "dateTime": "2026-10-30T09:00:00.000Z",
  "endDate": "2026-10-31T21:00:00.000Z",
  "registrationDeadline": "2026-10-29T23:59:59.000Z",
  "capacity": 150,
  "registeredCount": 142,
  "activityPoints": 50,
  "status": "Upcoming", // Upcoming, Ongoing, Completed, Cancelled
  "organizerId": "usr_faculty_01",
  "coordinatorName": "Dr. Sarah Mitchell",
  "checkInSecretToken": "CHK_CODESPARK_2026",
  "createdAt": "2026-10-01T00:00:00.000Z"
}
```

#### C. `registrations/{eventId}_{studentId}` Collection
Deterministic compound document key (`registrations/{eventId}_{studentId}`) preventing race condition duplicate registrations at the database level.
```json
{
  "id": "evt_01_std_05",
  "registrationId": "evt_01_std_05",
  "eventId": "evt_01",
  "eventTitle": "National Hackathon 2026: CodeSpark",
  "studentId": "std_05",
  "studentRollNumber": "22CS105",
  "studentName": "Siddharth Nair",
  "studentEmail": "siddharth.n@college.edu",
  "studentDepartment": "Computer Science & Engineering",
  "status": "registered", // registered, cancelled, waitlisted
  "registeredAt": "2026-10-25T14:30:00.000Z",
  "cancelledAt": null,
  "updatedAt": "2026-10-25T14:30:00.000Z"
}
```

#### D. `attendance/{eventId}_{studentRollNumber}` Collection
Event roll-call and QR check-in records. Compound doc ID ensures zero duplicate check-in records.
```json
{
  "id": "evt_01_22cs105",
  "attendanceId": "evt_01_22cs105",
  "eventId": "evt_01",
  "eventTitle": "National Hackathon 2026: CodeSpark",
  "studentId": "std_05",
  "studentRollNumber": "22CS105",
  "studentName": "Siddharth Nair",
  "studentDepartment": "Computer Science & Engineering",
  "status": "Present", // Present, Absent, Excused
  "timestamp": "2026-10-26T09:15:00.000Z",
  "markedBy": "Dr. Sarah Mitchell",
  "verifyingUserId": "usr_faculty_01",
  "checkInMode": "QR Code Pass" // "QR Code Pass", "Manual Roll Call", "Bulk Roll Call"
}
```

---

### 2. Validation & Security Enforcement

| Validation Rule | Enforcement Layer | Behavior |
|---|---|---|
| **Duplicate Student ID** | UI Form + Firestore Pre-query | Rejects addition if `studentId` / `rollNumber` already exists in `students`. |
| **Admin Protection** | UI (Hidden Buttons) + Controller + `firestore.rules` | Non-admin mutation calls throw unauthorized access errors. |
| **Event Capacity > 0** | UI Form + Controller + Model | Rejects `capacity <= 0` with informative validation message. |
| **Date Hierarchy** | UI Form + Controller | Enforces `endDate >= startDate` and `registrationDeadline <= startDate`. |
| **Event Registration Capacity** | Firestore Transaction (`runTransaction`) | Reads authoritative event doc, verifies `registeredCount < capacity`, atomic increment. |
| **Registration Deadline** | Client + Firestore Transaction | Rejects registration if `DateTime.now() > registrationDeadline`. |
| **Duplicate Registration** | Compound Key + Firestore Transaction | Ensures a student cannot hold duplicate active registrations. |
| **QR Code Authenticity** | Firestore Backend Verification | Validates scanned `qrToken` against the authoritative event's `checkInSecretToken`. |
| **Duplicate Attendance** | Compound Key (`{eventId}_{roll}`) + Repository | Prevents double check-in for attendees already marked 'Present'. |

---

### 3. CSV Batch Import Specification

Administrators can bulk-provision student cohorts via the **CSV Import Modal** in the Students Roster screen.

#### Standard Header Format
```csv
studentId,name,email,department,year,section,interests
22CS101,Aditya Sharma,aditya.s@college.edu,Computer Science & Engineering,3rd Year,A,AI; Machine Learning; Cloud
22IT102,Meera Krishnan,meera.k@college.edu,Information Technology,2nd Year,B,Web Development; Cyber Security
```

#### Parsing & Validation Engine (`StudentCsvParser`):
1. **Intra-Batch Deduplication**: Flags duplicate student IDs encountered within the same file.
2. **Database Collision Detection**: Cross-references against all existing student IDs currently in Firestore.
3. **Field Validation**: Verifies mandatory name, valid email regex (`@` and `.`), and academic year range (1-5).
4. **Interest Delimiters**: Supports both `;` and `,` for multi-interest tokenization.
5. **Interactive Error Reporting**: Displays an interactive modal table listing line number, student ID, column field, and exact reason for failed rows.

---

### 4. QR Code Attendance Verification Workflow

```
[Student Device]                        [Faculty / Admin Scanner]                 [Cloud Firestore]
       │                                            │                                      │
       │─── Opens "Show QR Pass" ──────────────────>│                                      │
       │    (Contains Event ID + Roll Number +      │                                      │
       │     Authoritative Event Secret Token)      │                                      │
       │                                            │─── Scans Pass in Scanner Modal ─────>│
       │                                            │    (Calls verifyAndRecordQrCheckIn)  │
       │                                            │                                      │
       │                                            │<── Authoritative Event Token Check ──│
       │                                            │    & Conflict Duplicate Prevention   │
       │                                            │                                      │
       │                                            │─── Writes {eventId}_{roll} Record ──>│
       │                                            │    (Status: 'Present',               │
       │                                            │     verifyingUserId: uid,            │
       │                                            │     checkInMode: 'QR Code Pass')     │
       │<── Instant Confirmation Banner ────────────│<── Success Confirmation ─────────────│
```

---

### 5. Automated Verification & Testing

The project maintains **100% test passing status** with 0 analyzer issues:

```bash
# Static analysis
flutter analyze
# Output: No issues found! (ran in 4.3s)

# Full test suite execution (36 unit & integration tests)
flutter test
# Output: 00:09 +36: All tests passed!
```

#### Test Coverage Summary:
- `test/auth_test.dart`: Role RBAC security, admin bootstrap tokens, public registration constraints.
- `test/crud_test.dart`:
  - Student creation with duplicate ID prevention.
  - Admin-only student record deletion protection.
  - CSV parser header validation, intra-batch duplicate detection, and database collision detection.
  - Event capacity (> 0), date hierarchy, and deadline validation.
  - Event cancellation workflow with audit logs.
  - Atomic student registration and capacity limit enforcement.
  - Registration release upon student cancellation.
  - Faculty roll-call status updates (`Present`, `Absent`, `Excused`).
  - Secret token QR attendance verification and forged token rejection.
  - Duplicate attendance check-in rejection.
- `test/unit_test.dart`: UserModel getters, controllers metric calculations, report generation.
- `test/widget_test.dart`: App smoke test, navigation mounting, and dashboard rendering.

---

### 6. Manual Testing Checklist

| Test Case | Steps to Execute | Expected Result |
|---|---|---|
| **Add Student** | 1. Sign in as Admin (`admin@college.edu`).<br>2. Navigate to Students Roster (`/students`).<br>3. Click "Add Student", enter unique roll number (e.g. `24CS999`). | Student record created, toast confirmation, added to roster. |
| **Prevent Duplicate Student** | 1. In "Add Student", enter an existing roll number (`22CS101`).<br>2. Click "Save Record". | Error banner: *"Student with Roll Number 22CS101 already exists."* |
| **Admin Privilege Guard** | 1. Switch role to Faculty or Student.<br>2. Notice "Add Student" and "Import CSV" buttons are hidden.<br>3. Edit/Delete actions in student rows are disabled. | Non-admins cannot mutate student master roster. |
| **CSV Batch Import** | 1. As Admin, click "Import CSV" in Students screen.<br>2. Click "Insert Demo CSV Data" and click "Validate & Import". | Displays summary (valid rows vs error rows), lists line numbers & reasons for invalid rows. |
| **Event Date Validation** | 1. As Faculty/Admin, go to Events (`/events`) and click "Create Event".<br>2. Set End Date earlier than Start Date. | Form validator blocks submission: *"End date cannot be earlier than start date."* |
| **Event Registration** | 1. Sign in as Student (`student@college.edu`).<br>2. Go to Event Registration (`/event-registration`).<br>3. Click "Register Now" on an open event. | Button flips to *"Enrolled (Click to Cancel)"*, spots decrement by 1. |
| **Cancel Registration** | 1. On an enrolled event, click "Enrolled (Click to Cancel)".<br>2. Confirm slot release in dialog. | Button restores to *"Register Now"*, spots increment by 1. |
| **QR Pass Check-In** | 1. On Attendance screen (`/attendance`), click "Show QR Pass" to preview QR token.<br>2. Click "Scan QR Code", enter roll number and matching event secret token (`CHK_CODESPARK_2026`).<br>3. Click "Verify & Check In". | Instant verification, attendee marked 'Present', live present count increments. |
| **Duplicate Check-In Rejection**| 1. Scan the same student roll number again with valid token. | Error banner: *"Student is already checked in as Present for this event."* |
