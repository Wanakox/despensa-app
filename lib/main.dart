import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/despensa_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } on FirebaseException {
    // El modo local continúa disponible hasta añadir google-services.json.
  }
  runApp(const DespensaApp());
}
