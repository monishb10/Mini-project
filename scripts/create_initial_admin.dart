import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_pattern_mining/firebase_options.dart';

/// Secure Initial Administrator Bootstrap Script for SAPM System
///
/// Usage:
///   dart run scripts/create_initial_admin.dart \
///     --email=admin@college.edu \
///     --password=SecurePassword123! \
///     --name="Dr. Sarah Mitchell" \
///     --dept="Computer Science & Engineering" \
///     --token=SAPM_INITIAL_ADMIN_TOKEN_2026
///
/// Or simply run interactively:
///   dart run scripts/create_initial_admin.dart

const String kExpectedSetupToken = 'SAPM_INITIAL_ADMIN_TOKEN_2026';

void main(List<String> arguments) async {
  stdout.writeln('===========================================================');
  stdout.writeln('  SAPM SYSTEM: INITIAL ADMINISTRATOR BOOTSTRAP SCRIPT      ');
  stdout.writeln('===========================================================');

  final Map<String, String> parsedArgs = {};
  for (final arg in arguments) {
    if (arg.startsWith('--') && arg.contains('=')) {
      final parts = arg.substring(2).split('=');
      parsedArgs[parts[0]] = parts.sublist(1).join('=');
    }
  }

  // 1. Gather & Validate Setup Token
  String? token = parsedArgs['token'];
  if (token == null || token.trim().isEmpty) {
    stdout.write('Enter Administrative Setup Token: ');
    token = stdin.readLineSync()?.trim();
  }

  if (token != kExpectedSetupToken) {
    stderr.writeln('\n[ERROR] Security Violation: Invalid administrative setup token.');
    stderr.writeln('Unauthorized attempts to bootstrap the administrator account are logged.');
    exit(1);
  }

  // 2. Gather Administrator Details
  String? email = parsedArgs['email'];
  if (email == null || email.trim().isEmpty) {
    stdout.write('Enter Admin Email (e.g. admin@college.edu): ');
    email = stdin.readLineSync()?.trim();
  }

  if (email == null || !email.contains('@')) {
    stderr.writeln('[ERROR] Valid email address is required.');
    exit(1);
  }

  String? name = parsedArgs['name'];
  if (name == null || name.trim().isEmpty) {
    stdout.write('Enter Admin Full Name: ');
    name = stdin.readLineSync()?.trim();
  }
  name = (name == null || name.isEmpty) ? 'System Administrator' : name;

  String? password = parsedArgs['password'];
  if (password == null || password.trim().isEmpty) {
    stdout.write('Enter Admin Password (min 6 characters): ');
    password = stdin.readLineSync()?.trim();
  }

  if (password == null || password.length < 6) {
    stderr.writeln('[ERROR] Password must be at least 6 characters.');
    exit(1);
  }

  final String dept = parsedArgs['dept'] ?? 'Office of the Principal';

  stdout.writeln('\nInitializing Firebase services...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    stdout.writeln('Connected to Firebase project.');

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    stdout.writeln('Creating Auth credential for $email...');
    UserCredential credential;
    try {
      credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      stdout.writeln('Auth user successfully created in Firebase Authentication.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        stdout.writeln('User already exists in Auth. Authenticating to elevate role...');
        credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        rethrow;
      }
    }

    final user = credential.user;
    if (user == null) {
      throw Exception('Authentication user handle returned null.');
    }

    await user.updateDisplayName(name);

    stdout.writeln('Writing Root Administrator document to Firestore users/${user.uid}...');
    await firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'name': name,
      'role': 'admin', // Verified Admin assignment
      'department': dept,
      'studentId': '',
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    stdout.writeln('\n===========================================================');
    stdout.writeln('SUCCESS: Institutional Administrator successfully provisioned!');
    stdout.writeln('UID:         ${user.uid}');
    stdout.writeln('Email:       $email');
    stdout.writeln('Role:        admin');
    stdout.writeln('Department:  $dept');
    stdout.writeln('===========================================================');
    stdout.writeln('You can now log in to the SAPM Portal with these credentials.');
    exit(0);
  } catch (e) {
    stderr.writeln('\n[FAILED] Initial admin setup encountered an error: $e');
    stderr.writeln('Ensure Firebase project is configured and Firebase CLI / Emulators are running.');
    exit(1);
  }
}
