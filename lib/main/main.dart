import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fordev/main/factories/pages/login/login_page_factory.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../ui/components/components.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return GetMaterialApp(
        title: '4Dev',
        debugShowCheckedModeBanner: false,
        theme: makeAppTheme(),
        initialRoute: '/login',
        getPages: [
          GetPage(name: '/login', page: makeLoginPage),
        ]);
  }
}
