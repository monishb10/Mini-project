import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/page_header.dart';
import '../controllers/pattern_mining_controller.dart';

class PatternMiningScreen extends StatelessWidget {
  const PatternMiningScreen({super.key});

  void _showAlgorithmHelpModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Apriori & Pattern Mining Methodology'),
          ],
        ),
        content: const SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is Student Activity Pattern Mining?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  'The Apriori algorithm detects hidden associations between co-occurring activities in student attendance histories. By generating frequent itemsets, the system discovers rules of the form {A} => {B}.',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 12),
                Text(
                  'Key Mining Metrics:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  '• Support: Frequency of rule items across all student cohorts (P(A ∩ B)).',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  '• Confidence: Conditional probability that B occurs given A (P(B|A)).',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  '• Lift: Strength of association over random chance. Lift > 1 indicates genuine positive behavioral affinity.',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 12),
                Text(
                  'Behavioral Clustering:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  'Unsupervised clustering partitions students into behavioral archetypes (e.g. Tech Innovators vs At-Risk Disengaged), enabling proactive academic interventions and personalized event recommendations.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<PatternMiningController>();

    final rules = controller.rules;
    final clusters = controller.clusters;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Student Activity Pattern Mining Engine',
              subtitle:
                  'Apriori association rules, frequent itemsets, and behavioral student cohort segmentation',
              actions: [
                OutlinedButton.icon(
                  onPressed: () => _showAlgorithmHelpModal(context),
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label: const Text('Algorithm Guide'),
                ),
                ElevatedButton.icon(
                  onPressed: controller.isMiningRunning
                      ? null
                      : () => controller.executeMiningJob(),
                  icon: controller.isMiningRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    controller.isMiningRunning
                        ? 'Computing Apriori...'
                        : 'Re-Mine Patterns',
                  ),
                ),
              ],
            ),

            // Apriori Interactive Controls Panel
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mining Parameters & Thresholds (Apriori Engine)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          controller.algorithm,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 14),

                  // Sliders Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 800;

                      final minSupportWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Min Support Threshold',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${(controller.minSupport * 100).toInt()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: controller.minSupport,
                            min: 0.10,
                            max: 0.50,
                            divisions: 8,
                            onChanged: (val) =>
                                controller.updateParameters(minSupport: val),
                          ),
                        ],
                      );

                      final minConfWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Min Confidence Threshold',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${(controller.minConfidence * 100).toInt()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: controller.minConfidence,
                            min: 0.50,
                            max: 0.95,
                            divisions: 9,
                            onChanged: (val) =>
                                controller.updateParameters(minConfidence: val),
                          ),
                        ],
                      );

                      final minLiftWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Min Lift Ratio',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${controller.minLift.toStringAsFixed(2)}x',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: controller.minLift,
                            min: 1.0,
                            max: 3.0,
                            divisions: 20,
                            onChanged: (val) =>
                                controller.updateParameters(minLift: val),
                          ),
                        ],
                      );

                      if (isNarrow) {
                        return Column(
                          children: [
                            minSupportWidget,
                            const SizedBox(height: 12),
                            minConfWidget,
                            const SizedBox(height: 12),
                            minLiftWidget,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: minSupportWidget),
                          const SizedBox(width: 24),
                          Expanded(child: minConfWidget),
                          const SizedBox(width: 24),
                          Expanded(child: minLiftWidget),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Discovered Association Rules Section
            Row(
              children: [
                const Icon(
                  Icons.account_tree_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Discovered Association Rules (${rules.length} valid rules satisfying thresholds)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: LoadingState(
                  message: 'Executing pattern mining algorithms...',
                ),
              )
            else if (rules.isEmpty)
              EmptyState(
                title: 'No Association Rules Met Selected Criteria',
                description:
                    'Try reducing the Minimum Support or Minimum Confidence threshold using the sliders above.',
                actionLabel: 'Reset Thresholds',
                onAction: () => controller.updateParameters(
                  minSupport: 0.20,
                  minConfidence: 0.60,
                  minLift: 1.20,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rules.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  return AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  _buildTag(
                                    rule.antecedents.join(" + "),
                                    AppColors.primary,
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: AppColors.textMutedLight,
                                  ),
                                  _buildTag(
                                    rule.consequents.join(" + "),
                                    AppColors.secondary,
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Lift: ${rule.lift.toStringAsFixed(2)}x',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          rule.academicInterpretation,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceSecondaryDark
                                : AppColors.surfaceSecondaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                size: 18,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Actionable Intervention: ${rule.recommendedIntervention}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Support: ${(rule.support * 100).toInt()}% of population',
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Confidence: ${(rule.confidence * 100).toInt()}% certainty',
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 28),

            // Student Behavioral Clusters Section
            Row(
              children: [
                const Icon(
                  Icons.bubble_chart_outlined,
                  color: AppColors.clusterA,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Student Cohort Behavioral Clusters (K-Means Profiling)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = width < 720 ? 1 : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: width < 720 ? 1.5 : 1.6,
                  ),
                  itemCount: clusters.length,
                  itemBuilder: (context, index) {
                    final cluster = clusters[index];
                    final isRisk = cluster.riskRating == 'High Risk';

                    return AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  cluster.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isRisk
                                      ? AppColors.errorLight
                                      : AppColors.successLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  cluster.riskRating,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isRisk
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cluster.description,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                '${cluster.studentCount} Students (${cluster.percentage}%)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intervention Action: ${cluster.actionPlan}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMutedLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
