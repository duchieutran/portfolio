import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/core/services/error_service.dart';
import 'package:portfolio/firebase_options.dart';
import 'package:portfolio/presentation/app.dart';

Future<void> main() async {
  await ErrorService.initGlobalErrorHandler(
    () async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(const App());
    },
  );
}
