import 'package:firebase_core/firebase_core.dart';

/// Configuration Firebase
class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // Clés Firebase
        apiKey: 'AIzaSyBN2gyH-1IT11qEZ4_48iTtLsbnHXJFPXI',
        appId: '1:22776216354:web:069c916a063db46906837b',
        messagingSenderId: '22776216354',
        projectId: 'land-tg',
        storageBucket: 'land-tg.firebasestorage.app',

        // Android
        androidClientId: 'YOUR_ANDROID_CLIENT_ID',

        // iOS
        iosClientId: 'YOUR_IOS_CLIENT_ID',
        iosBundleId: 'com.togostay.app',
      ),
    );
  }
}
