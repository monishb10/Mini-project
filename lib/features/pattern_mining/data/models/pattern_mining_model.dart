class AssociationRule {
  final String id;
  final List<String> antecedents;
  final List<String> consequents;
  final double support;
  final double confidence;
  final double lift;
  final String academicInterpretation;
  final String recommendedIntervention;

  const AssociationRule({
    required this.id,
    required this.antecedents,
    required this.consequents,
    required this.support,
    required this.confidence,
    required this.lift,
    required this.academicInterpretation,
    required this.recommendedIntervention,
  });

  String get ruleFormula =>
      '{ ${antecedents.join(", ")} } => { ${consequents.join(", ")} }';
}

class FrequentItemset {
  final List<String> items;
  final double support;
  final int count;

  const FrequentItemset({
    required this.items,
    required this.support,
    required this.count,
  });
}

class StudentCluster {
  final String id;
  final String name;
  final String description;
  final int studentCount;
  final double percentage;
  final List<String> dominantCategories;
  final String riskRating; // 'Low', 'Moderate', 'High Risk'
  final String actionPlan;

  const StudentCluster({
    required this.id,
    required this.name,
    required this.description,
    required this.studentCount,
    required this.percentage,
    required this.dominantCategories,
    required this.riskRating,
    required this.actionPlan,
  });
}

class PatternMiningRunConfig {
  final double minSupport;
  final double minConfidence;
  final double minLift;
  final String algorithm; // 'Apriori', 'FP-Growth', 'K-Means Clustering'
  final String targetDepartment;

  const PatternMiningRunConfig({
    this.minSupport = 0.20,
    this.minConfidence = 0.60,
    this.minLift = 1.20,
    this.algorithm = 'Apriori Algorithm',
    this.targetDepartment = 'All Departments',
  });
}
