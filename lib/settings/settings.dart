import 'package:flutter/material.dart';
import 'package:work_time_tracker/settings/projects/projects_screen.dart';
import 'package:work_time_tracker/settings/settings_main_screen.dart';

class Routes {
  static const root = "/";
  static const projects = "/projects";
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _key = GlobalKey<NavigatorState>();

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      Routes.root: (context) => const SettingsMainScreen(),
      Routes.projects: (context) => const SettingsProjectsPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    return WillPopScope(
      onWillPop: () {
        if(_key.currentState != null && _key.currentState!.canPop()) {
          _key.currentState!.pop();
          return Future(() => false);
        }
        return Future(() => true);
      },
      child: Navigator(
        key: _key,
        initialRoute: Routes.root,
        onGenerateRoute: (routeSettings) => MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name]!(context),
        ),
      ),
    );
  }
}
