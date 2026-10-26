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
