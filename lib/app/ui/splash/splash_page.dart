import 'package:cobonno/app/app.dart';
import 'package:flutter/material.dart';

import '../../common/shared_code.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      Uri? deepLink = MyApp.getDeepLink(context);
      //debugPrint('deep link is ${deepLink.toString()}');
      if (deepLink != null) {
        SharedCode(context).handleDeepLink(deepLink, appRouter: MyApp.getAppRouter(context));
      } else {
        SharedCode(context).handleAuthenticationRouting();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SharedCode.lightStatusBar(),
        toolbarHeight: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(child: Container()),
              Expanded(child: Image.asset('assets/splash.png')),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }
}
