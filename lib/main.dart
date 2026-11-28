import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/features/auth/data/auth_service.dart';
import 'package:visualcheckup/features/auth/data/firebase_social_auth_adapter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase asynchronously with a safety timeout so it never blocks
  // runApp or causes the native splash screen to hang/freeze.
  unawaited(
    Firebase.initializeApp().timeout(const Duration(seconds: 4)).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      debugPrint('Firebase initialization skipped/failed: $error');
      return Firebase.app();
    }),
  );

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
