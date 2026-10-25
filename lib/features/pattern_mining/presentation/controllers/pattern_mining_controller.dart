import 'package:flutter/material.dart';
import '../../data/models/pattern_mining_model.dart';
import '../../data/repositories/pattern_mining_repository.dart';

class PatternMiningController extends ChangeNotifier {
  final PatternMiningRepository _repository;

  List<AssociationRule> _rules = [];
  List<FrequentItemset> _itemsets = [];
  List<StudentCluster> _clusters = [];
  PatternMiningRunConfig _config = const PatternMiningRunConfig();

  bool _isLoading = false;
  bool _isMiningRunning = false;
  String? _errorMessage;

  PatternMiningController({PatternMiningRepository? repository})
    : _repository = repository ?? MockPatternMiningRepository() {
    loadData();
  }

  List<AssociationRule> get rules => _rules;
  List<FrequentItemset> get itemsets => _itemsets;
  List<StudentCluster> get clusters => _clusters;
  PatternMiningRunConfig get config => _config;
  bool get isLoading => _isLoading;
  bool get isMiningRunning => _isMiningRunning;
  String? get errorMessage => _errorMessage;

  double get minSupport => _config.minSupport;
  double get minConfidence => _config.minConfidence;
  double get minLift => _config.minLift;
  String get algorithm => _config.algorithm;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getAssociationRules(_config),
        _repository.getFrequentItemsets(_config.minSupport),
        _repository.getStudentClusters(),
      ]);

      _rules = results[0] as List<AssociationRule>;
      _itemsets = results[1] as List<FrequentItemset>;
      _clusters = results[2] as List<StudentCluster>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateParameters({
    double? minSupport,
    double? minConfidence,
    double? minLift,
    String? algorithm,
    String? targetDepartment,
  }) {
    _config = PatternMiningRunConfig(
      minSupport: minSupport ?? _config.minSupport,
      minConfidence: minConfidence ?? _config.minConfidence,
      minLift: minLift ?? _config.minLift,
      algorithm: algorithm ?? _config.algorithm,
      targetDepartment: targetDepartment ?? _config.targetDepartment,
    );
    loadData();
  }

  Future<void> executeMiningJob() async {
    _isMiningRunning = true;
    notifyListeners();

    try {
      await _repository.runMiningJob(_config);
      await loadData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isMiningRunning = false;
      notifyListeners();
    }
  }
}
