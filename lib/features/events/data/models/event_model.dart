class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String venue;
  final String organizerDepartment;
  final DateTime dateTime;
  final DateTime? endDate;
  final DateTime? registrationDeadline;
  final double durationHours;
  final int capacity;
  final int registeredCount;
  final int activityPoints;
  final String status; // 'Upcoming', 'Ongoing', 'Completed', 'Cancelled'
  final String coordinatorName;
  final String? organizerId;
  final String? checkInSecretToken;
  final DateTime? createdAt;
  final bool isRegistered;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.venue,
    required this.organizerDepartment,
    required this.dateTime,
    this.endDate,
    this.registrationDeadline,
    required this.durationHours,
    required this.capacity,
    required this.registeredCount,
    required this.activityPoints,
    required this.status,
    required this.coordinatorName,
    this.organizerId,
    this.checkInSecretToken,
    this.createdAt,
    this.isRegistered = false,
  });

  // Aliases for Part 3 specifications
  String get eventId => id;
  String get department => organizerDepartment;
  DateTime get startDate => dateTime;
  DateTime get effectiveEndDate =>
      endDate ?? dateTime.add(Duration(minutes: (durationHours * 60).round()));
  DateTime get effectiveRegistrationDeadline =>
      registrationDeadline ?? dateTime.subtract(const Duration(hours: 2));

  bool get isFull => registeredCount >= capacity;
  bool get isRegistrationClosed =>
      DateTime.now().isAfter(effectiveRegistrationDeadline);
  bool get canRegister =>
      !isFull && !isRegistrationClosed && status == 'Upcoming' && !isRegistered;
  double get occupancyRate =>
      capacity == 0 ? 0.0 : (registeredCount / capacity).clamp(0.0, 1.0);

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? venue,
    String? organizerDepartment,
    DateTime? dateTime,
    DateTime? endDate,
    DateTime? registrationDeadline,
    double? durationHours,
    int? capacity,
    int? registeredCount,
    int? activityPoints,
    String? status,
    String? coordinatorName,
    String? organizerId,
    String? checkInSecretToken,
    DateTime? createdAt,
    bool? isRegistered,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      venue: venue ?? this.venue,
      organizerDepartment: organizerDepartment ?? this.organizerDepartment,
      dateTime: dateTime ?? this.dateTime,
      endDate: endDate ?? this.endDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      durationHours: durationHours ?? this.durationHours,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      activityPoints: activityPoints ?? this.activityPoints,
      status: status ?? this.status,
      coordinatorName: coordinatorName ?? this.coordinatorName,
      organizerId: organizerId ?? this.organizerId,
      checkInSecretToken: checkInSecretToken ?? this.checkInSecretToken,
      createdAt: createdAt ?? this.createdAt,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': id,
    'title': title,
    'description': description,
    'category': category,
    'venue': venue,
    'department': organizerDepartment,
    'organizerDepartment': organizerDepartment,
    'dateTime': dateTime.toIso8601String(),
    'startDate': dateTime.toIso8601String(),
    'endDate': effectiveEndDate.toIso8601String(),
    'registrationDeadline': effectiveRegistrationDeadline.toIso8601String(),
    'durationHours': durationHours,
    'capacity': capacity,
    'registeredCount': registeredCount,
    'activityPoints': activityPoints,
    'status': status,
    'coordinatorName': coordinatorName,
    'organizerId': organizerId ?? '',
    'checkInSecretToken': checkInSecretToken ?? '',
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    'isRegistered': isRegistered,
  };

  Map<String, dynamic> toFirestore() => {
    'eventId': id,
    'title': title,
    'description': description,
    'category': category,
    'venue': venue,
    'department': organizerDepartment,
    'organizerDepartment': organizerDepartment,
    'startDate': dateTime.toIso8601String(),
    'dateTime': dateTime.toIso8601String(),
    'endDate': effectiveEndDate.toIso8601String(),
    'registrationDeadline': effectiveRegistrationDeadline.toIso8601String(),
    'durationHours': durationHours,
    'capacity': capacity,
    'registeredCount': registeredCount,
    'activityPoints': activityPoints,
    'status': status,
    'coordinatorName': coordinatorName,
    'organizerId': organizerId ?? '',
    'checkInSecretToken': checkInSecretToken ?? 'TOKEN_${id.toUpperCase()}',
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final start = json['startDate'] ?? json['dateTime'];
    final startDt = start != null
        ? DateTime.tryParse(start as String) ?? DateTime.now()
        : DateTime.now();
    final end = json['endDate'];
    final endDt = end != null ? DateTime.tryParse(end as String) : null;
    final deadline = json['registrationDeadline'];
    final deadlineDt =
        deadline != null ? DateTime.tryParse(deadline as String) : null;
    final created = json['createdAt'];
    final createdDt =
        created != null ? DateTime.tryParse(created as String) : null;

    final dept = (json['department'] ?? json['organizerDepartment']) as String? ??
        'General';

    return EventModel(
      id: (json['eventId'] ?? json['id']) as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Technical',
      venue: json['venue'] as String? ?? 'Auditorium',
      organizerDepartment: dept,
      dateTime: startDt,
      endDate: endDt,
      registrationDeadline: deadlineDt,
      durationHours: (json['durationHours'] as num?)?.toDouble() ?? 2.0,
      capacity: (json['capacity'] as num?)?.toInt() ?? 50,
      registeredCount: (json['registeredCount'] as num?)?.toInt() ?? 0,
      activityPoints: (json['activityPoints'] as num?)?.toInt() ?? 25,
      status: json['status'] as String? ?? 'Upcoming',
      coordinatorName: json['coordinatorName'] as String? ?? 'Coordinator',
      organizerId: json['organizerId'] as String?,
      checkInSecretToken: json['checkInSecretToken'] as String?,
      createdAt: createdDt,
      isRegistered: json['isRegistered'] as bool? ?? false,
    );
  }

  factory EventModel.fromFirestore(
    Map<String, dynamic> json,
    String docId, {
    bool isRegisteredForCurrentUser = false,
  }) {
    final start = json['startDate'] ?? json['dateTime'];
    final startDt = start != null
        ? DateTime.tryParse(start as String) ?? DateTime.now()
        : DateTime.now();
    final end = json['endDate'];
    final endDt = end != null ? DateTime.tryParse(end as String) : null;
    final deadline = json['registrationDeadline'];
    final deadlineDt =
        deadline != null ? DateTime.tryParse(deadline as String) : null;
    final created = json['createdAt'];
    final createdDt =
        created != null ? DateTime.tryParse(created as String) : null;

    final dept = (json['department'] ?? json['organizerDepartment']) as String? ??
        'General';

    return EventModel(
      id: docId,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Technical',
      venue: json['venue'] as String? ?? 'Auditorium',
      organizerDepartment: dept,
      dateTime: startDt,
      endDate: endDt,
      registrationDeadline: deadlineDt,
      durationHours: (json['durationHours'] as num?)?.toDouble() ?? 2.0,
      capacity: (json['capacity'] as num?)?.toInt() ?? 50,
      registeredCount: (json['registeredCount'] as num?)?.toInt() ?? 0,
      activityPoints: (json['activityPoints'] as num?)?.toInt() ?? 25,
      status: json['status'] as String? ?? 'Upcoming',
      coordinatorName: json['coordinatorName'] as String? ?? 'Coordinator',
      organizerId: json['organizerId'] as String?,
      checkInSecretToken: json['checkInSecretToken'] as String?,
      createdAt: createdDt,
      isRegistered: isRegisteredForCurrentUser,
    );
  }
}
