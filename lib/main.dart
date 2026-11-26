import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/features/auth/data/auth_service.dart';
import 'package:visualcheckup/features/auth/data/firebase_social_auth_adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Runs gracefully in local-first mode if Firebase config files are not yet added.
  }
  runApp(
    VisualCheckUpApp(
      authService: LocalAuthService(
        socialAdapter: FirebaseSocialAuthAdapter(
          serverClientId:
              '913513035294-j15rpm5rsldng6rm60gse2cf660ighmb.apps.googleusercontent.com',
        ),
      ),
    ),
  );
}
