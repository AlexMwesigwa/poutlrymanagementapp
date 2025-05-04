import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apms/models/farm_data_model.dart';
import 'package:apms/models/alert_model.dart';

class FarmProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FarmData? _currentData;
  List<FarmData> _historicalData = [];
  List<AlertModel> _alerts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  FarmData? get currentData => _currentData;
  List<FarmData> get historicalData => _historicalData;
  List<AlertModel> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Get current farm data
  Future<void> fetchCurrentData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot =
          await _firestore
              .collection('farm_data')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        _currentData = FarmData.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch current farm data.';
      notifyListeners();
    }
  }

  // Get historical farm data
  Future<void> fetchHistoricalData({int days = 7}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final snapshot =
          await _firestore
              .collection('farm_data')
              .where('timestamp', isGreaterThanOrEqualTo: startDate)
              .orderBy('timestamp', descending: true)
              .get();

      _historicalData =
          snapshot.docs
              .map((doc) => FarmData.fromMap(doc.data(), doc.id))
              .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch historical farm data.';
      notifyListeners();
    }
  }

  // Get alerts
  Future<void> fetchAlerts({int limit = 20}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot =
          await _firestore
              .collection('alerts')
              .orderBy('timestamp', descending: true)
              .limit(limit)
              .get();

      _alerts =
          snapshot.docs
              .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
              .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch alerts.';
      notifyListeners();
    }
  }

  // Mark alert as read
  Future<void> markAlertAsRead(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'isRead': true,
      });

      // Update local state
      final index = _alerts.indexWhere((alert) => alert.id == alertId);
      if (index != -1) {
        _alerts[index] = _alerts[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to mark alert as read.';
      notifyListeners();
    }
  }

  // Update temperature threshold
  Future<void> updateTemperatureThreshold(double min, double max) async {
    try {
      await _firestore.collection('settings').doc('thresholds').update({
        'temperature': {'min': min, 'max': max},
      });
    } catch (e) {
      _errorMessage = 'Failed to update temperature threshold.';
      notifyListeners();
    }
  }

  // Update humidity threshold
  Future<void> updateHumidityThreshold(double min, double max) async {
    try {
      await _firestore.collection('settings').doc('thresholds').update({
        'humidity': {'min': min, 'max': max},
      });
    } catch (e) {
      _errorMessage = 'Failed to update humidity threshold.';
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
