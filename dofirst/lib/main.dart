import 'package:dofirst/app/app.dart';
import 'package:dofirst/shared/services/focus_background_task.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background timer monitoring
  await FocusBackgroundTask().init();
  
  runApp(const DoFirstApp());
}
