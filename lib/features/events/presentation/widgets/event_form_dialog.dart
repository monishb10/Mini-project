import 'package:flutter/material.dart';
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
  late DateTime _dateTime;

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

    _category = e?.category ?? AppConstants.eventCategories.first;
    _department = e?.organizerDepartment ?? AppConstants.departments.first;
    _status = e?.status ?? 'Upcoming';
    _dateTime = e?.dateTime ?? DateTime.now().add(const Duration(days: 7));
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final event = EventModel(
      id: widget.eventToEdit?.id ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _category,
      venue: _venueController.text.trim(),
      organizerDepartment: _department,
      dateTime: _dateTime,
      durationHours: widget.eventToEdit?.durationHours ?? 4.0,
      capacity: int.tryParse(_capacityController.text.trim()) ?? 100,
      registeredCount: widget.eventToEdit?.registeredCount ?? 0,
      activityPoints: int.tryParse(_pointsController.text.trim()) ?? 25,
      status: _status,
      coordinatorName: _coordinatorController.text.trim(),
      isRegistered: widget.eventToEdit?.isRegistered ?? false,
    );

    Navigator.of(context).pop(event);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Event Details' : 'Create New College Event',
      ),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: AppConstants.eventCategories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _category = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['Upcoming', 'Ongoing', 'Completed', 'Cancelled']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _status = val!),
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
                        decoration: const InputDecoration(
                          labelText: 'Campus Venue *',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                        validator: Validators.positiveNumber,
                        decoration: const InputDecoration(
                          labelText: 'Maximum Capacity *',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pointsController,
                        validator: Validators.positiveNumber,
                        decoration: const InputDecoration(
                          labelText: 'Activity Credits *',
                        ),
                      ),
                    ),
                  ],
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
          child: Text(isEditing ? 'Save Changes' : 'Publish Event'),
        ),
      ],
    );
  }
}
