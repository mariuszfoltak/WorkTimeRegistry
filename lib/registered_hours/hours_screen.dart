import 'package:flutter/material.dart';
import 'package:work_time_tracker/registered_hours/register_hours_screen.dart';
import 'package:work_time_tracker/registered_hours/registered_hours_screen.dart';

class Routes {
  static const root = "/";
  static const registerHours = "/register_hours";
}

class HoursPage extends StatefulWidget {
  const HoursPage({super.key});

  @override
  State<HoursPage> createState() => _HoursPageState();
}

class _HoursPageState extends State<HoursPage> {
  var key = GlobalKey();
  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      Routes.root: (context) => const RegisteredHoursPage(),
      Routes.registerHours: (context) => const RegisterHoursScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    return Navigator(
      key: key,
      initialRoute: Routes.root,
      onGenerateRoute: (routeSettings) => MaterialPageRoute(
        builder: (context) => routeBuilders[routeSettings.name]!(context),
      ),
    );
  }
}
