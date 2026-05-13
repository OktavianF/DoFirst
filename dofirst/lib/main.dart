import 'package:dofirst/app/app.dart';
import 'package:dofirst/shared/services/focus_background_task.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Background fetch is not available on web, so skip it there.
  if (!kIsWeb) {
    await FocusBackgroundTask().init();
  }
  
  runApp(const DoFirstApp());
}
