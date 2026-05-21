import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/period_settings_model.dart';

class PeriodSettingsProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  PeriodSettingsModel _settings = const PeriodSettingsModel(userId: '');
  PeriodSettingsModel get settings => _settings;

  int get startDay => _settings.startDay;
  int get endDay => _settings.endDay;

  Future<void> loadSettings(String userId) async {
    try {
      final doc = await _db.collection('period_settings').doc(userId).get();
      if (doc.exists) {
        _settings = PeriodSettingsModel.fromMap(doc.data()!);
      } else {
        _settings = PeriodSettingsModel.defaultSettings(userId);
      }
      notifyListeners();
    } catch (_) {
      _settings = PeriodSettingsModel.defaultSettings(userId);
      notifyListeners();
    }
  }

  Future<void> saveSettings(String userId, int startDay, int endDay) async {
    final newSettings = PeriodSettingsModel(
      userId: userId,
      startDay: startDay,
      endDay: endDay,
    );
    await _db.collection('period_settings').doc(userId).set(newSettings.toMap());
    _settings = newSettings;
    notifyListeners();
  }
}
