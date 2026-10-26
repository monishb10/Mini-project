import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/event_model.dart';

class EventFormDialog extends StatefulWidget {
  final EventModel? eventToEdit;

  const EventFormDialog({super.key, this.eventToEdit});

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _venueController;
  late TextEditingController _coordinatorController;
  late TextEditingController _capacityController;
  late TextEditingController _pointsController;

  late String _category;
  late String _department;
  late String _status;
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _registrationDeadline;
  String? _dateValidationError;

  static const List<String> _categories = [
    'Technical',
    'Workshop',
    'Seminar',
    'Cultural',
    'Sports',
    'Social Service',
    'Hackathons & Ideathons',
    'Leadership & Governance',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.eventToEdit;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _venueController = TextEditingController(text: e?.venue ?? '');
    _coordinatorController = TextEditingController(
      text: e?.coordinatorName ?? '',
    );
    _capacityController = TextEditingController(
      text: e?.capacity.toString() ?? '100',
    );
    _pointsController = TextEditingController(
      text: e?.activityPoints.toString() ?? '25',
    );

    _category = e?.category != null && _categories.contains(e!.category)
        ? e.category
        : _categories.first;
    _department = e?.organizerDepartment ?? AppConstants.departments.first;
    _status = e?.status ?? 'Upcoming';
    _startDate = e?.dateTime ?? DateTime.now().add(const Duration(days: 7));
    _endDate = e?.effectiveEndDate ?? _startDate.add(const Duration(hours: 4));
    _registrationDeadline =
        e?.effectiveRegistrationDeadline ?? _startDate.subtract(const Duration(hours: 4));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _coordinatorController.dispose();
    _capacityController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _dateValidationError = null);

    // Validate dates
    if (_endDate.isBefore(_startDate)) {
      setState(() {
        _dateValidationError = 'End date cannot be earlier than start date.';
      });
      return;
    }

    if (_registrationDeadline.isAfter(_startDate)) {
      setState(() {
        _dateValidationError =
            'Registration deadline cannot be set after the event start date.';
      });
      return;
    }

    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    if (capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capacity must be a positive integer greater than zero.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final durationHours = _endDate.difference(_startDate).inMinutes / 60.0;

    final event = EventModel(
      id: widget.eventToEdit?.id ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _category,
      venue: _venueController.text.trim(),
      organizerDepartment: _department,
      dateTime: _startDate,
      endDate: _endDate,
      registrationDeadline: _registrationDeadline,
      durationHours: durationHours > 0 ? durationHours : 2.0,
      capacity: capacity,
      registeredCount: widget.eventToEdit?.registeredCount ?? 0,
      activityPoints: int.tryParse(_pointsController.text.trim()) ?? 25,
      status: _status,
      coordinatorName: _coordinatorController.text.trim(),
      organizerId: widget.eventToEdit?.organizerId,
      checkInSecretToken: widget.eventToEdit?.checkInSecretToken,
      createdAt: widget.eventToEdit?.createdAt ?? DateTime.now(),
      isRegistered: widget.eventToEdit?.isRegistered ?? false,
    );

    Navigator.of(context).pop(event);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Event Details' : 'Create New College Event'),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_dateValidationError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _dateValidationError!,
                            style: const TextStyle(color: AppColors.error, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                TextFormField(
                  controller: _titleController,
                  validator: Validators.required,
                  decoration: const InputDecoration(labelText: 'Event Title *'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descController,
                  validator: Validators.required,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Event Description & Objectives *',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'Category *'),
                        items: _categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _department,
                        decoration: const InputDecoration(labelText: 'Department *'),
                        items: AppConstants.departments
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _department = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _venueController,
                        validator: Validators.required,
                        decoration: const InputDecoration(labelText: 'Venue / Hall *'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _coordinatorController,
                        validator: Validators.required,
                        decoration: const InputDecoration(
                          labelText: 'Faculty Coordinator *',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          final num = int.tryParse(val ?? '');
                          if (num == null || num <= 0) {
                            return 'Capacity must be > 0';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Seat Capacity *',
                          hintText: 'e.g. 100',
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _pointsController,
                        keyboardType: TextInputType.number,
                        validator: Validators.required,
                        decoration: const InputDecoration(
                          labelText: 'Activity Points *',
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Upcoming',
                            child: Text('Upcoming'),
                          ),
                          DropdownMenuItem(
                            value: 'Ongoing',
                            child: Text('Ongoing'),
                          ),
                          DropdownMenuItem(
                            value: 'Completed',
                            child: Text('Completed'),
                          ),
                          DropdownMenuItem(
                            value: 'Cancelled',
                            child: Text('Cancelled'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Date & Deadline Pickers
                const Text(
                  'Event Timeline & Registration Deadlines:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 10),

                // Start Date & Time
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDateTime(
                          initial: _startDate,
                          onPicked: (dt) => setState(() => _startDate = dt),
                        ),
                        icon: const Icon(Icons.event_available, size: 16),
                        label: Text(
                          'Start: ${DateFormat.yMd().add_jm().format(_startDate)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // End Date & Time
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDateTime(
                          initial: _endDate,
                          onPicked: (dt) => setState(() => _endDate = dt),
                        ),
                        icon: const Icon(Icons.event_busy, size: 16),
                        label: Text(
                          'End: ${DateFormat.yMd().add_jm().format(_endDate)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Registration Deadline
                OutlinedButton.icon(
                  onPressed: () => _pickDateTime(
                    initial: _registrationDeadline,
                    onPicked: (dt) => setState(() => _registrationDeadline = dt),
                  ),
                  icon: const Icon(Icons.timer_outlined, size: 16, color: AppColors.warning),
                  label: Text(
                    'Registration Deadline: ${DateFormat.yMd().add_jm().format(_registrationDeadline)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save Changes' : 'Create Event'),
        ),
      ],
    );
  }
}
