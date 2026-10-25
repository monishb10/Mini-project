import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/student_model.dart';

class StudentFormDialog extends StatefulWidget {
  final StudentModel? studentToEdit;

  const StudentFormDialog({super.key, this.studentToEdit});

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _rollController;
  late TextEditingController _emailController;
  late TextEditingController _cgpaController;
  late TextEditingController _pointsController;

  late String _department;
  late String _year;
  late String _section;
  late String _riskLevel;
  late String _clusterGroup;

  @override
  void initState() {
    super.initState();
    final s = widget.studentToEdit;
    _nameController = TextEditingController(text: s?.name ?? '');
    _rollController = TextEditingController(text: s?.rollNumber ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _cgpaController = TextEditingController(text: s?.cgpa.toString() ?? '8.0');
    _pointsController = TextEditingController(
      text: s?.activityPoints.toString() ?? '50',
    );

    _department = s?.department ?? AppConstants.departments.first;
    _year = s?.year ?? AppConstants.years.first;
    _section = s?.section ?? 'A';
    _riskLevel = s?.riskLevel ?? 'Low';
    _clusterGroup = s?.clusterGroup ?? 'Tech Innovators';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _emailController.dispose();
    _cgpaController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final student = StudentModel(
      id: widget.studentToEdit?.id ?? '',
      rollNumber: _rollController.text.trim(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      department: _department,
      year: _year,
      section: _section,
      cgpa: double.tryParse(_cgpaController.text.trim()) ?? 8.0,
      totalEventsAttended: widget.studentToEdit?.totalEventsAttended ?? 2,
      activityPoints: int.tryParse(_pointsController.text.trim()) ?? 50,
      clusterGroup: _clusterGroup,
      riskLevel: _riskLevel,
      attendanceRate: widget.studentToEdit?.attendanceRate ?? 85.0,
      preferredCategories:
          widget.studentToEdit?.preferredCategories ?? ['Technical & Coding'],
      enrolledAt: widget.studentToEdit?.enrolledAt ?? DateTime.now(),
    );

    Navigator.of(context).pop(student);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.studentToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Student Details' : 'Add New Student'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        controller: _nameController,
                        validator: Validators.required,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _rollController,
                        validator: Validators.studentId,
                        decoration: const InputDecoration(
                          labelText: 'Roll No *',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  validator: Validators.email,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _department,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                        ),
                        items: AppConstants.departments
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _department = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _year,
                        decoration: const InputDecoration(labelText: 'Year'),
                        items: AppConstants.years
                            .map(
                              (y) => DropdownMenuItem(value: y, child: Text(y)),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _year = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _riskLevel,
                        decoration: const InputDecoration(
                          labelText: 'Risk Level',
                        ),
                        items: ['Low', 'Medium', 'High']
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _riskLevel = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cgpaController,
                        validator: (val) => Validators.required(val),
                        decoration: const InputDecoration(
                          labelText: 'CGPA (0.0 - 10.0)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pointsController,
                        validator: (val) => Validators.positiveNumber(val),
                        decoration: const InputDecoration(
                          labelText: 'Activity Credits',
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
          child: Text(isEditing ? 'Save Changes' : 'Create Student'),
        ),
      ],
    );
  }
}
