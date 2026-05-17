import 'package:dofirst/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dofirst/shared/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleSignIn.instance.initialize(
    clientId: '1075110912203-o3cl8onk5pc2o2bfaujb6jv93ufinbfj.apps.googleusercontent.com',
    serverClientId: kIsWeb ? null : '1075110912203-o3cl8onk5pc2o2bfaujb6jv93ufinbfj.apps.googleusercontent.com',
  );

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const DoFirstApp());
}
