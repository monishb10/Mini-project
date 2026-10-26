import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static bool _useEmulators = false;
  static String? _initError;

  static bool get isInitialized => _initialized;
  static bool get isUsingEmulators => _useEmulators;
  static String? get initError => _initError;

  /// Initialize Firebase with options
  static Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      _initError = null;
      debugPrint('[FirebaseService] Successfully initialized Firebase');
      return true;
    } catch (e) {
      _initError = e.toString();
      debugPrint('[FirebaseService] Firebase initialization note: $e');
      // If already initialized by native layer
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        _initError = null;
        return true;
      }
      return false;
    }
  }

  /// Connect to local Firebase Emulator Suite (Auth & Firestore)
  static Future<void> connectToEmulators({
    String host = 'localhost',
    int authPort = 9099,
    int firestorePort = 8080,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      await FirebaseAuth.instance.useAuthEmulator(host, authPort);
      FirebaseFirestore.instance.useFirestoreEmulator(host, firestorePort);
      _useEmulators = true;
      debugPrint(
        '[FirebaseService] Connected to Firebase Emulator Suite on $host (Auth: $authPort, Firestore: $firestorePort)',
      );
    } catch (e) {
      debugPrint('[FirebaseService] Emulator connection notice: $e');
    }
  }
}
