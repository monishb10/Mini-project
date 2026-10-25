import '../models/pattern_mining_model.dart';

abstract class PatternMiningRepository {
  Future<List<AssociationRule>> getAssociationRules(
    PatternMiningRunConfig config,
  );
  Future<List<FrequentItemset>> getFrequentItemsets(double minSupport);
  Future<List<StudentCluster>> getStudentClusters();
  Future<void> runMiningJob(PatternMiningRunConfig config);
}

class MockPatternMiningRepository implements PatternMiningRepository {
  final List<AssociationRule> _allRules = const [
    AssociationRule(
      id: 'rule_01',
      antecedents: ['Python Programming Workshop', 'Data Structures Bootcamp'],
      consequents: ['National Hackathon 2026'],
      support: 0.38,
      confidence: 0.86,
      lift: 2.26,
      academicInterpretation:
          'Students who complete foundational programming and data structures workshops have an 86% likelihood of registering for competitive hackathons (2.26x industry baseline).',
      recommendedIntervention:
          'Fast-track these students into specialized mentoring tracks for Smart India Hackathon and ACM ICPC.',
    ),
    AssociationRule(
      id: 'rule_02',
      antecedents: ['AI & Machine Learning Symposium'],
      consequents: ['Cloud Native Bootcamp', 'Research Paper Presentation'],
      support: 0.29,
      confidence: 0.78,
      lift: 1.95,
      academicInterpretation:
          'Participation in AI research seminars strongly cascades into cloud deployment workshops and research paper publications.',
      recommendedIntervention:
          'Provide subsidized cloud credits (Google Cloud / AWS) and faculty research co-authorships.',
    ),
    AssociationRule(
      id: 'rule_03',
      antecedents: ['Cultural Fest Organizing Committee'],
      consequents: [
        'Leadership & Governance Summit',
        'Alumni Networking Dinner',
      ],
      support: 0.24,
      confidence: 0.81,
      lift: 2.10,
      academicInterpretation:
          'Event coordinators and cultural managers demonstrate high affinity for institutional leadership and corporate communication events.',
      recommendedIntervention:
          'Recommend for Student Council leadership roles and college placement cell representation.',
    ),
    AssociationRule(
      id: 'rule_04',
      antecedents: ['Sports & Athletics Meet'],
      consequents: ['Fitness & Wellness Workshop'],
      support: 0.31,
      confidence: 0.72,
      lift: 1.80,
      academicInterpretation:
          'Athletic participants sustain interest in sports science and physical wellness programs.',
      recommendedIntervention:
          'Schedule morning conditioning sessions and ensure no conflict with core technical exam timetables.',
    ),
    AssociationRule(
      id: 'rule_05',
      antecedents: ['First-Year Induction Program', 'Library Orientation'],
      consequents: ['Coding Club Orientation'],
      support: 0.44,
      confidence: 0.65,
      lift: 1.45,
      academicInterpretation:
          'Early positive engagement during induction correlates with continuous 1st-year club membership.',
      recommendedIntervention:
          'Mandate senior peer-mentors for early student onboarding in August semester.',
    ),
  ];

  final List<FrequentItemset> _allItemsets = const [
    FrequentItemset(
      items: ['Python Workshop', 'Hackathon 2026'],
      support: 0.42,
      count: 420,
    ),
    FrequentItemset(
      items: ['Data Structures Bootcamp', 'Hackathon 2026'],
      support: 0.39,
      count: 390,
    ),
    FrequentItemset(
      items: ['AI Symposium', 'Cloud Native Workshop'],
      support: 0.32,
      count: 320,
    ),
    FrequentItemset(
      items: ['Cultural Fest', 'Leadership Summit'],
      support: 0.26,
      count: 260,
    ),
    FrequentItemset(
      items: ['Python Workshop', 'Data Structures', 'Hackathon 2026'],
      support: 0.28,
      count: 280,
    ),
  ];

  final List<StudentCluster> _clusters = const [
    StudentCluster(
      id: 'cls_01',
      name: 'Tech Innovators & Hackers',
      description:
          'High-performing students who actively compete in coding challenges, hackathons, and software engineering bootcamps.',
      studentCount: 520,
      percentage: 36.6,
      dominantCategories: [
        'Technical & Coding',
        'Hackathons & Ideathons',
        'Workshops & Seminars',
      ],
      riskRating: 'Low',
      actionPlan:
          'Facilitate industry-sponsored grand challenge hackathons and seed funding for student startups.',
    ),
    StudentCluster(
      id: 'cls_02',
      name: 'Cultural & Creative Leaders',
      description:
          'Students driving extracurricular vitality through music, dance, theatre, design, and literature clubs.',
      studentCount: 380,
      percentage: 26.8,
      dominantCategories: [
        'Cultural & Arts',
        'Social Outreach',
        'Leadership & Governance',
      ],
      riskRating: 'Low',
      actionPlan:
          'Provide sound stages, exhibition galleries, and budget allocations for regional inter-college competitions.',
    ),
    StudentCluster(
      id: 'cls_03',
      name: 'Athletic & Sports Regulars',
      description:
          'Competitive athletes participating in state and university varsity tournaments with disciplined physical activity.',
      studentCount: 290,
      percentage: 20.4,
      dominantCategories: ['Sports & Athletics', 'Fitness & Wellness'],
      riskRating: 'Moderate',
      actionPlan:
          'Grant sports attendance credit exemptions and offer flexible examination time slots during tournaments.',
    ),
    StudentCluster(
      id: 'cls_04',
      name: 'At-Risk Disengaged Cohort',
      description:
          'Students who have attended less than 2 activities this academic year and show signs of academic isolation.',
      studentCount: 230,
      percentage: 16.2,
      dominantCategories: ['None / Sporadic'],
      riskRating: 'High Risk',
      actionPlan:
          'Urgent notification to Faculty Mentors. Implement compulsory 1-on-1 counseling and low-barrier introductory events.',
    ),
  ];

  @override
  Future<List<AssociationRule>> getAssociationRules(
    PatternMiningRunConfig config,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allRules.where((rule) {
      return rule.support >= config.minSupport &&
          rule.confidence >= config.minConfidence &&
          rule.lift >= config.minLift;
    }).toList();
  }

  @override
  Future<List<FrequentItemset>> getFrequentItemsets(double minSupport) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allItemsets.where((item) => item.support >= minSupport).toList();
  }

  @override
  Future<List<StudentCluster>> getStudentClusters() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _clusters;
  }

  @override
  Future<void> runMiningJob(PatternMiningRunConfig config) async {
    // Simulate algorithmic calculation delay
    await Future.delayed(const Duration(milliseconds: 800));
  }
}
