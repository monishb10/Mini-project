class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String venue;
  final String organizerDepartment;
  final DateTime dateTime;
  final double durationHours;
  final int capacity;
  final int registeredCount;
  final int activityPoints;
  final String status; // 'Upcoming', 'Ongoing', 'Completed', 'Cancelled'
  final String coordinatorName;
  final bool isRegistered;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.venue,
    required this.organizerDepartment,
    required this.dateTime,
    required this.durationHours,
    required this.capacity,
    required this.registeredCount,
    required this.activityPoints,
    required this.status,
    required this.coordinatorName,
    this.isRegistered = false,
  });

  bool get isFull => registeredCount >= capacity;
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
    double? durationHours,
    int? capacity,
    int? registeredCount,
    int? activityPoints,
    String? status,
    String? coordinatorName,
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
      durationHours: durationHours ?? this.durationHours,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      activityPoints: activityPoints ?? this.activityPoints,
      status: status ?? this.status,
      coordinatorName: coordinatorName ?? this.coordinatorName,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'venue': venue,
    'organizerDepartment': organizerDepartment,
    'dateTime': dateTime.toIso8601String(),
    'durationHours': durationHours,
    'capacity': capacity,
    'registeredCount': registeredCount,
    'activityPoints': activityPoints,
    'status': status,
    'coordinatorName': coordinatorName,
    'isRegistered': isRegistered,
  };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    category: json['category'] as String,
    venue: json['venue'] as String,
    organizerDepartment: json['organizerDepartment'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    durationHours: (json['durationHours'] as num).toDouble(),
    capacity: json['capacity'] as int,
    registeredCount: json['registeredCount'] as int,
    activityPoints: json['activityPoints'] as int,
    status: json['status'] as String,
    coordinatorName: json['coordinatorName'] as String,
    isRegistered: json['isRegistered'] as bool? ?? false,
  );
}
