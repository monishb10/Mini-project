import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/page_header.dart';
import '../controllers/report_controller.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  void _showGenerateReportModal(BuildContext context) {
    final titleController = TextEditingController();
    String reportType = 'Accreditation Compliance';
    String department = 'All Departments';
    String format = 'PDF';

    final types = [
      'Accreditation Compliance',
      'Student Mentoring Audit',
      'Academic Credit Summary',
      'Pattern Mining Research',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Generate Formal Institutional Report'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Report Title *',
                      hintText: 'e.g. NAAC Metric 5.3 Audit 2026',
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: reportType,
                    decoration: const InputDecoration(labelText: 'Report Type'),
                    items: types
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setModalState(() => reportType = val!),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: department,
                    decoration: const InputDecoration(
                      labelText: 'Department Scope',
                    ),
                    items: ['All Departments', ...AppConstants.departments]
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
                    onChanged: (val) => setModalState(() => department = val!),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: format,
                    decoration: const InputDecoration(
                      labelText: 'Export Format',
                    ),
                    items: ['PDF', 'CSV', 'XLSX']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) => setModalState(() => format = val!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final reportCtrl = context.read<ReportController>();
                final title = titleController.text.trim().isEmpty
                    ? 'Generated Report - ${DateFormat.yMd().format(DateTime.now())}'
                    : titleController.text.trim();
                Navigator.of(ctx).pop();
                final success = await reportCtrl.generateReport(
                  title: title,
                  reportType: reportType,
                  department: department,
                  academicYear: AppConstants.academicYear,
                  format: format,
                );
                if (success && mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Report "$title" compiled successfully!'),
                    ),
                  );
                }
              },
              child: const Text('Generate Report'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<ReportController>();
    final reports = controller.reports;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Institutional Audit & Accreditation Reports',
              subtitle:
                  'Export verified student activity summaries for NAAC, NBA, NIRF, and academic credit verification',
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _showGenerateReportModal(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Generate Report'),
                ),
              ],
            ),

            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: LoadingState(
                  message: 'Compiling institutional records...',
                ),
              )
            else if (reports.isEmpty)
              EmptyState(
                title: 'No Reports Generated Yet',
                description:
                    'Generate institutional accreditation or mentoring reports to export audit-ready summaries.',
                actionLabel: 'Generate First Report',
                onAction: () => _showGenerateReportModal(context),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final report = reports[index];

                  return AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getFormatBg(report.fileFormat),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                report.fileFormat,
                                style: TextStyle(
                                  color: _getFormatColor(report.fileFormat),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Scope: ${report.department} • AY ${report.academicYear} • Generated by ${report.generatedBy}',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                report.status,
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          report.summaryHighlights,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Includes ${report.recordsCount} verified student records • ${DateFormat.yMMMd().format(report.generatedAt)}',
                              style: theme.textTheme.labelMedium,
                            ),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Downloading "${report.title}.${report.fileFormat.toLowerCase()}"...',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.file_download_outlined,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Download ${report.fileFormat}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                  tooltip: 'Delete Report',
                                  onPressed: () =>
                                      controller.deleteReport(report.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getFormatColor(String format) {
    switch (format) {
      case 'PDF':
        return AppColors.error;
      case 'CSV':
        return AppColors.success;
      case 'XLSX':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
  }

  Color _getFormatBg(String format) {
    switch (format) {
      case 'PDF':
        return AppColors.errorLight;
      case 'CSV':
        return AppColors.successLight;
      case 'XLSX':
        return AppColors.primaryContainer;
      default:
        return AppColors.surfaceSecondaryLight;
    }
  }
}
