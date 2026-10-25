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

## 🧪 Evaluation Quick Logins

The login screen features 1-click chips for instant evaluation without typing:
- **Admin**: `admin@college.edu` (Dr. Sarah Mitchell - CSE)
- **Faculty**: `faculty@college.edu` (Prof. Rajesh Sharma - IT)
- **Student**: `student@college.edu` (Aarav Patel - Roll No: `22CS104`)

*(You can also quickly switch roles at any point from the top of the Sidebar or from the Profile & Settings screen).*
