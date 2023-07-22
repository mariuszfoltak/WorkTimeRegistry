import 'package:flutter/material.dart';
import 'package:work_time_tracker/settings/settings_clients.dart';
import 'package:work_time_tracker/settings/settings_root.dart';

class Routes {
  static const root = "/";
  static const clients = "/clients";
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      Routes.root: (context) => const SettingsRootPage(),
      Routes.clients: (context) => const SettingsClientsPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    return Navigator(
      key: GlobalKey(),
      initialRoute: Routes.root,
      onGenerateRoute: (routeSettings) => MaterialPageRoute(
        builder: (context) => routeBuilders[routeSettings.name]!(context),
      ),
    );
  }
}
