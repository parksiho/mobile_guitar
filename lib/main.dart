import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/sequence_editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MobileGuitarApp());
}

class MobileGuitarApp extends StatelessWidget {
  const MobileGuitarApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color seed = Color(0xFF6D4C41);
    return MaterialApp(
      title: '코드 연주',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ko'),
      supportedLocales: const <Locale>[Locale('ko')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SequenceEditorScreen(),
    );
  }
}
