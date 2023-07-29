import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:work_time_tracker/model/database.dart';
import 'package:work_time_tracker/registered_hours/hours_screen.dart';
import 'package:work_time_tracker/settings/settings.dart';

WTTDatabase database = WTTDatabase();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Work Time Tracker'),
      supportedLocales: const [
        Locale('en', 'EN'),
        Locale('pl', 'PL'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HoursPage(),
    Icon(Icons.abc, size: 150),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: "Godziny",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Estymacja",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Ustawienia",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (value) => setState(() {
          _selectedIndex = value;
        }),
      ),
      body: _pages.elementAt(_selectedIndex),
    );
  }
}
