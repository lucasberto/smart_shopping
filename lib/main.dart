import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopping/screens/auth.dart';
import 'package:smart_shopping/screens/shopping_lists.dart';
import 'package:smart_shopping/screens/splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_shopping/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MainApp()));
}

MaterialScheme currentMaterialScheme = MaterialTheme.lightScheme();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Lists',
      theme: MaterialTheme(Theme.of(context).textTheme).light(),
      darkTheme: MaterialTheme(Theme.of(context).textTheme).dark(),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    currentMaterialScheme =
        Theme.of(context).colorScheme.brightness == Brightness.light
            ? MaterialTheme.lightScheme()
            : MaterialTheme.darkScheme();

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          return const ShoppingListsScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
