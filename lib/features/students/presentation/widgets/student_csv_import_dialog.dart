import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/csv_import_result.dart';
import '../controllers/student_controller.dart';

class StudentCsvImportDialog extends StatefulWidget {
  const StudentCsvImportDialog({super.key});

  @override
  State<StudentCsvImportDialog> createState() => _StudentCsvImportDialogState();
}

class _StudentCsvImportDialogState extends State<StudentCsvImportDialog> {
  final _csvTextController = TextEditingController();
  bool _isImporting = false;
  CsvImportResult? _result;

  static const String _sampleCsvTemplate =
      'studentId,name,email,department,year,section,interests\n'
      '22CS201,Kavya Sharma,kavya.s@college.edu,Computer Science & Engineering,3rd Year,A,Technical & Coding;Hackathons\n'
      '22IT202,Manish Rao,manish.r@college.edu,Information Technology,3rd Year,B,Web Development;Cybersecurity\n'
      '23EC203,Deepak Nair,deepak.n@college.edu,Electronics & Communication,2nd Year,A,Robotics;IoT;Embedded Systems\n'
      '23ME204,Pooja Hegde,pooja.h@college.edu,Mechanical Engineering,2nd Year,B,CAD Design;Automotive;Sports\n'
      '24AI205,Vikram Sethi,vikram.s@college.edu,Artificial Intelligence & Data Science,1st Year,A,Machine Learning;Data Science';

  @override
  void dispose() {
    _csvTextController.dispose();
    super.dispose();
  }

  void _loadSampleTemplate() {
    setState(() {
      _csvTextController.text = _sampleCsvTemplate;
      _result = null;
    });
  }

  Future<void> _handleImport() async {
    final text = _csvTextController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or paste CSV content before importing.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authController = context.read<AuthController>();
    final studentController = context.read<StudentController>();

    setState(() {
      _isImporting = true;
      _result = null;
    });

    final res = await studentController.importCsv(
      text,
      isAdmin: authController.isAdmin,
    );

    if (mounted) {
      setState(() {
        _isImporting = false;
        _result = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = context.watch<AuthController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Batch Import Students via CSV',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Upload student records with automatic validation and duplicate detection.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 28),

              // Authorization Warning if not Admin
              if (!authController.isAdmin) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withAlpha(80)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, color: AppColors.error, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Administrative Privilege Required: Only Administrators can write or import student records.',
                          style: TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Format hint bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CSV Data (Comma-separated with headers):',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  TextButton.icon(
                    onPressed: _loadSampleTemplate,
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: const Text('Load Sample Template', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Text Area
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _csvTextController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'studentId,name,email,department,year,section,interests\n22CS101,Aarav Patel,aarav.p@college.edu,Computer Science & Engineering,3rd Year,A,Coding;Hackathons',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),

              // Results summary & Error reporting table
              if (_result != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _result!.hasErrors
                        ? AppColors.errorLight
                        : AppColors.successLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _result!.hasErrors
                          ? AppColors.error.withAlpha(80)
                          : AppColors.success.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _result!.hasErrors ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                        color: _result!.hasErrors ? AppColors.error : AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Results: ${_result!.importedCount} imported, ${_result!.skippedCount} skipped / rejected out of ${_result!.totalRows} total rows.',
                          style: TextStyle(
                            color: _result!.hasErrors ? AppColors.error : AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error breakdown table
                if (_result!.hasErrors) ...[
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withAlpha(50)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.separated(
                        itemCount: _result!.errors.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final err = _result!.errors[idx];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.errorLight,
                              child: Text(
                                '${err.lineNumber}',
                                style: const TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              '[${err.field}] ${err.reason}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text('ID: ${err.studentId}', style: const TextStyle(fontSize: 11)),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isImporting || !authController.isAdmin
                        ? null
                        : _handleImport,
                    icon: _isImporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload_rounded, size: 18),
                    label: Text(_isImporting ? 'Validating & Importing...' : 'Validate & Import Records'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
