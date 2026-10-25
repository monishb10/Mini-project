class AppConstants {
  AppConstants._();

  static const String appName = 'Student Activity Pattern Mining';
  static const String appShortName = 'SAPM System';
  static const String institutionName = 'Institute of Technology & Engineering';
  static const String academicYear = '2025-2026';
  static const String currentSemester = 'Even Semester (Spring 2026)';

  // College Departments
  static const List<String> departments = [
    'Computer Science & Engineering',
    'Information Technology',
    'Electronics & Communication',
    'Electrical & Electronics',
    'Mechanical Engineering',
    'Civil Engineering',
    'Biotechnology',
  ];

  // Academic Years
  static const List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  // Event Categories
  static const List<String> eventCategories = [
    'Technical & Coding',
    'Hackathons & Ideathons',
    'Workshops & Seminars',
    'Cultural & Arts',
    'Sports & Athletics',
    'Social & Community Outreach',
    'Leadership & Governance',
  ];

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleFaculty = 'faculty';
  static const String roleStudent = 'student';

  // Participation Status
  static const String statusPresent = 'Present';
  static const String statusAbsent = 'Absent';
  static const String statusExcused = 'Excused';

  // Event Status
  static const String eventUpcoming = 'Upcoming';
  static const String eventOngoing = 'Ongoing';
  static const String eventCompleted = 'Completed';
  static const String eventCancelled = 'Cancelled';

  // Pattern Mining Default Parameters
  static const double defaultMinSupport = 0.20; // 20%
  static const double defaultMinConfidence = 0.60; // 60%
  static const double defaultMinLift = 1.20;
}
